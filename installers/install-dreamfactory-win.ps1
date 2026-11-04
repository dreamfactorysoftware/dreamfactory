<#
.SYNOPSIS
  Unattended DreamFactory 7.x install on Windows Server 2025 (IIS + PHP 8.3 NTS FastCGI).
  Mirrors the "Installing DreamFactory on Windows Server" guide, chapter by chapter, with
  every step verified and idempotent so it can be re-run or run one phase at a time.
  Phases: Prep, Php, SqlServer (ODBC Driver 17 + 18 and the sqlsrv/pdo_sqlsrv extensions;
  -SkipSqlServer leaves them out), Composer, DreamFactory, Iis, Verify.

.NOTES
  Run elevated (SSM Run Command runs as SYSTEM, which is fine).
  Log: C:\df-install\install.log   State: C:\df-install\state\<phase>.done
  Never echoes AdminPassword or LicenseKey.
#>
[CmdletBinding()]
param(
  [ValidateSet('All','Prep','Php','SqlServer','Composer','DreamFactory','Iis','Verify')]
  [string]$Phase = 'All',

  # PHP (DreamFactory 7.7 requires PHP ^8.3; NTS x64 build, VS16 => VC++ 2015-2022 x64 runtime)
  [string]$PhpVersion = '8.3.36-1',
  [string]$PhpZipUrl  = '',           # override; default built from $PhpVersion
  [string]$PhpDir     = 'C:\PHP_8.3',

  # SQL Server connector: Microsoft ODBC Driver 17 + 18 and the matching msphpsql DLLs (installed by default)
  [switch]$SkipSqlServer,
  [string]$SqlsrvVersion = '5.13.3',  # msphpsql release; must ship DLLs for the PHP major.minor in $PhpVersion

  # DreamFactory source
  [string]$DfRepo    = 'https://github.com/dreamfactorysoftware/dreamfactory',
  [string]$DfRef     = '',            # tag/branch; '' = default branch
  [string]$DfDir     = 'C:\inetpub\wwwroot\dreamfactory',
  [string]$ComposerFilesDir = '',     # dir holding commercial composer.json / composer-dist.json / composer.lock
  [string]$LicenseKey = '',
  [string]$GithubToken = '',          # for composer's github vcs repos (commercial); used via COMPOSER_AUTH env only, never written to disk

  # System DB + first admin
  [ValidateSet('sqlite','mysql','pgsql','sqlsrv')]
  [string]$DbConnection = 'sqlite',
  [string]$DbHost = '', [string]$DbPort = '', [string]$DbDatabase = '', [string]$DbUsername = '', [string]$DbPassword = '',
  [string]$AdminFirst = 'DF', [string]$AdminLast = 'Admin',
  [string]$AdminEmail = 'admin@example.com',
  [string]$AdminPassword = '',
  [string]$AdminPhone = '000-000-0000',   # df:setup on develop rejects an empty phone (and exits 0 doing so)

  # IIS
  [string]$SiteName = 'dreamfactory',
  [int]$SitePort = 80,
  [switch]$SkipIeEsc
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$Work  = 'C:\df-install'; $Dl = "$Work\downloads"; $State = "$Work\state"
New-Item -ItemType Directory -Force -Path $Work,$Dl,$State | Out-Null
Start-Transcript -Path "$Work\install.log" -Append | Out-Null

function Log($m){ Write-Host ("[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }
function Done($p){ Test-Path "$State\$p.done" }
function MarkDone($p){ New-Item -ItemType File -Force -Path "$State\$p.done" | Out-Null }
function RefreshPath {
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
}
function AddMachinePath($dir){
  $p = [Environment]::GetEnvironmentVariable('Path','Machine')
  if (($p -split ';') -notcontains $dir) { [Environment]::SetEnvironmentVariable('Path', "$p;$dir", 'Machine'); Log "PATH += $dir" }
  RefreshPath
}
function Fetch($url, $out){
  if (Test-Path $out) { Log "cached $out"; return }
  Log "download $url"
  Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
}
function Run($exe, [string[]]$argv, [string]$cwd = $PWD){
  Log "> $exe $($argv -join ' ')"
  $p = Start-Process -FilePath $exe -ArgumentList $argv -WorkingDirectory $cwd -NoNewWindow -Wait -PassThru
  if ($p.ExitCode -ne 0) { throw "$exe exited $($p.ExitCode)" }
}
function Sh($cmdline, [string]$cwd = $PWD, [string]$show = ''){
  # run through cmd so .bat shims (composer) resolve; stream output. $show = redacted form for logs.
  if (-not $show) { $show = $cmdline }
  Log "> $show"
  Push-Location $cwd
  try { cmd /c "$cmdline 2>&1" | ForEach-Object { Write-Host $_ }; if ($LASTEXITCODE -ne 0) { throw "command exited $LASTEXITCODE : $show" } }
  finally { Pop-Location }
}
function Want($p){ $Phase -eq 'All' -or $Phase -eq $p }

Log "OS: $((Get-CimInstance Win32_OperatingSystem).Caption) build $([Environment]::OSVersion.Version.Build)"
Log "Running as: $([Security.Principal.WindowsIdentity]::GetCurrent().Name)"

# ---------------------------------------------------------------- Prep
if ((Want 'Prep') -and -not (Done 'Prep')) {
  Log '== Prep: IIS role, IE ESC, Git, VC++ runtime, URL Rewrite'
  $feat = Install-WindowsFeature Web-Server,Web-CGI,Web-Mgmt-Console,Web-Mgmt-Tools,Web-Scripting-Tools -IncludeManagementTools
  Log "IIS features: $($feat.ExitCode) restart=$($feat.RestartNeeded)"

  if (-not $SkipIeEsc) {
    foreach ($k in 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}',
                   'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}') {
      if (Test-Path $k) { Set-ItemProperty $k -Name IsInstalled -Value 0; Log "IE ESC off: $k" } else { Log "IE ESC key absent (expected on 2025): $k" }
    }
  }

  if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
    $rel = Invoke-RestMethod 'https://api.github.com/repos/git-for-windows/git/releases/latest' -UseBasicParsing
    $url = ($rel.assets | Where-Object name -like '*64-bit.exe' | Select-Object -First 1).browser_download_url
    Fetch $url "$Dl\git-setup.exe"
    Run "$Dl\git-setup.exe" @('/VERYSILENT','/NORESTART','/NOCANCEL','/SP-','/COMPONENTS=')
    AddMachinePath 'C:\Program Files\Git\cmd'
  }
  Log "git: $(git --version)"

  Fetch 'https://aka.ms/vs/17/release/vc_redist.x64.exe' "$Dl\vc_redist.x64.exe"
  $p = Start-Process "$Dl\vc_redist.x64.exe" -ArgumentList '/install','/quiet','/norestart' -Wait -PassThru -NoNewWindow
  if ($p.ExitCode -notin 0,1638,3010) { throw "vc_redist exit $($p.ExitCode)" }   # 1638 = newer already present
  Log "VC++ 2015-2022 x64 runtime: exit $($p.ExitCode)"

  if (-not (Test-Path "$env:windir\System32\inetsrv\rewrite.dll")) {
    Fetch 'https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi' "$Dl\rewrite_amd64.msi"
    Run 'msiexec.exe' @('/i',"$Dl\rewrite_amd64.msi",'/qn','/norestart')
  }
  Log "URL Rewrite: $(Test-Path "$env:windir\System32\inetsrv\rewrite.dll")"
  MarkDone 'Prep'
}

# ---------------------------------------------------------------- PHP
if ((Want 'Php') -and -not (Done 'Php')) {
  Log "== PHP $PhpVersion NTS x64 -> $PhpDir"
  if (-not $PhpZipUrl) { $PhpZipUrl = "https://downloads.php.net/~windows/releases/php-$PhpVersion-nts-Win32-vs16-x64.zip" }
  $zip = "$Dl\php-$PhpVersion-nts-x64.zip"
  Fetch $PhpZipUrl $zip
  if (-not (Test-Path "$PhpDir\php.exe")) { Expand-Archive -Path $zip -DestinationPath $PhpDir -Force }
  AddMachinePath $PhpDir

  $ini = "$PhpDir\php.ini"
  if (-not (Test-Path $ini)) { Copy-Item "$PhpDir\php.ini-production" $ini }
  $marker = '; --- DreamFactory settings (managed by install-dreamfactory-win.ps1) ---'
  if (-not (Select-String -Path $ini -SimpleMatch $marker -Quiet)) {
    @"

$marker
extension_dir = "$PhpDir\ext"
extension=ldap
extension=curl
extension=ffi
extension=ftp
extension=fileinfo
extension=gd
extension=intl
extension=mbstring
extension=exif
extension=mysqli
extension=odbc
extension=openssl
extension=pdo_mysql
extension=pdo_odbc
extension=pdo_pgsql
extension=pdo_sqlite
extension=pgsql
extension=shmop
extension=soap
extension=sockets
extension=sodium
extension=sqlite3
extension=tidy
extension=xsl
extension=zip
zend_extension=opcache
opcache.enable=1
opcache.enable_cli=0
; IIS FastCGI
cgi.force_redirect = 0
cgi.fix_pathinfo = 1
fastcgi.impersonate = 1
fastcgi.logging = 0
; runtime
date.timezone = UTC
memory_limit = 512M
max_execution_time = 300
upload_max_filesize = 64M
post_max_size = 64M
"@ | Add-Content -Path $ini -Encoding ASCII
  }
  $v = cmd /c "`"$PhpDir\php.exe`" -v 2>&1" | Select-Object -First 1
  Log "php: $v"
  $mods = cmd /c "`"$PhpDir\php.exe`" -m 2>&1"
  $need = 'curl','fileinfo','intl','mbstring','openssl','pdo_mysql','pdo_sqlite','sqlite3','zip','ldap','sodium'
  $missing = $need | Where-Object { $mods -notcontains $_ }
  if ($missing) { throw "PHP extensions failed to load: $($missing -join ', ')  (see php -m output above)" }
  Log "all required extensions loaded; opcache listed: $($mods -contains 'Zend OPcache')"
  MarkDone 'Php'
}

# ---------------------------------------------------------------- SQL Server
if ((Want 'SqlServer') -and -not $SkipSqlServer -and -not (Done 'SqlServer')) {
  Log "== SQL Server: ODBC Driver 17 + 18, sqlsrv/pdo_sqlsrv from msphpsql $SqlsrvVersion"
  if (-not (Test-Path "$PhpDir\php.exe")) { throw "PHP not found in $PhpDir; run the Php phase first" }
  foreach ($d in @(@{ v = '17'; link = '2249004' }, @{ v = '18'; link = '2249006' })) {
    $name = "ODBC Driver $($d.v) for SQL Server"
    if (Test-Path "HKLM:\SOFTWARE\ODBC\ODBCINST.INI\$name") { Log "$name already installed"; continue }
    $msi = "$Dl\msodbcsql$($d.v).msi"
    Fetch "https://go.microsoft.com/fwlink/?linkid=$($d.link)" $msi
    $p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" IACCEPTMSODBCSQLLICENSETERMS=YES /qn /norestart /l*v `"$Dl\msodbcsql$($d.v).log`"" -Wait -PassThru
    if ($p.ExitCode -notin 0,3010) { throw "$name msiexec exit $($p.ExitCode) (see $Dl\msodbcsql$($d.v).log)" }
    Log "$name installed (msiexec exit $($p.ExitCode))"
  }

  $tag = (($PhpVersion -split '\.')[0..1]) -join ''        # 8.3.36-1 -> 83
  $zip = "$Dl\msphpsql-$SqlsrvVersion.zip"
  Fetch "https://github.com/microsoft/msphpsql/releases/download/v$SqlsrvVersion/Windows_$($SqlsrvVersion)RTW.zip" $zip
  $x = "$Dl\msphpsql-$SqlsrvVersion"
  if (-not (Test-Path $x)) { Expand-Archive -Path $zip -DestinationPath $x -Force }
  foreach ($e in 'sqlsrv','pdo_sqlsrv') {
    $dll = "php_$($e)_$($tag)_nts_x64.dll"
    $src = Get-ChildItem $x -Recurse -Filter $dll | Select-Object -First 1
    if (-not $src) { throw "$dll is not in msphpsql $SqlsrvVersion; pick a release with PHP $tag DLLs via -SqlsrvVersion" }
    Copy-Item $src.FullName "$PhpDir\ext\php_$e.dll" -Force
    Log "ext\php_$e.dll <- $($src.Name)"
  }

  $ini = "$PhpDir\php.ini"
  $sqlMarker = '; --- SQL Server extensions (managed by install-dreamfactory-win.ps1) ---'
  if (-not (Select-String -Path $ini -SimpleMatch $sqlMarker -Quiet)) {
    "`n$sqlMarker`nextension=sqlsrv`nextension=pdo_sqlsrv" | Add-Content -Path $ini -Encoding ASCII
  }
  $out = cmd /c "`"$PhpDir\php.exe`" -m 2>&1"
  $warn = @($out | Where-Object { $_ -match 'Warning|Unable to load' })
  if ($warn) { throw "PHP startup warnings after enabling sqlsrv: $($warn -join ' | ')" }
  foreach ($e in 'sqlsrv','pdo_sqlsrv') { if ($out -notcontains $e) { throw "$e did not load (php -m)" } }
  Log 'sqlsrv + pdo_sqlsrv loaded'
  if (Done 'Iis') { Run "$env:windir\System32\iisreset.exe" @('/noforce'); Log 'iisreset so FastCGI picks up the new extensions' }
  MarkDone 'SqlServer'
}

# ---------------------------------------------------------------- Composer
if ((Want 'Composer') -and -not (Done 'Composer')) {
  Log '== Composer'
  RefreshPath
  $cdir = 'C:\composer'; New-Item -ItemType Directory -Force $cdir | Out-Null
  if (-not (Test-Path "$cdir\composer.phar")) {
    Fetch 'https://getcomposer.org/installer' "$Dl\composer-setup.php"
    Run "$PhpDir\php.exe" @("$Dl\composer-setup.php","--install-dir=$cdir","--filename=composer.phar","--quiet") $Dl
  }
  Set-Content "$cdir\composer.bat" "@php `"%~dp0composer.phar`" %*" -Encoding ASCII
  AddMachinePath $cdir
  [Environment]::SetEnvironmentVariable('COMPOSER_NO_INTERACTION','1','Machine'); $env:COMPOSER_NO_INTERACTION='1'
  Log "composer: $(cmd /c 'composer --version 2>&1' | Select-Object -First 1)"
  MarkDone 'Composer'
}

# ---------------------------------------------------------------- DreamFactory
if ((Want 'DreamFactory') -and -not (Done 'DreamFactory')) {
  Log "== DreamFactory -> $DfDir"
  RefreshPath; $env:COMPOSER_NO_INTERACTION='1'
  if (-not (Test-Path "$DfDir\artisan")) {
    $a = @('clone','--depth','1'); if ($DfRef) { $a += @('-b',$DfRef) }; $a += @($DfRepo,$DfDir)
    Run 'git.exe' $a 'C:\inetpub\wwwroot'
  }
  git config --global --add safe.directory ($DfDir -replace '\\','/') | Out-Null

  if ($ComposerFilesDir) {
    foreach ($f in 'composer.json','composer.json-dist','composer-dist.json','composer.lock') {
      if (Test-Path "$ComposerFilesDir\$f") { Copy-Item "$ComposerFilesDir\$f" "$DfDir\$f" -Force; Log "commercial $f in place" }
    }
    if (-not (Test-Path "$ComposerFilesDir\composer.lock")) { throw "ComposerFilesDir $ComposerFilesDir has no composer.lock" }
  }

  if ($GithubToken) { $env:COMPOSER_AUTH = '{"github-oauth":{"github.com":"' + $GithubToken + '"}}'; Log 'COMPOSER_AUTH set for github.com (token not logged)' }
  Sh 'composer install --no-dev --ignore-platform-reqs --prefer-dist --no-progress' $DfDir
  $env:COMPOSER_AUTH = $null

  if (-not (Test-Path "$DfDir\.env")) {
    $envArgs = "--db_connection=$DbConnection"
    if ($DbConnection -ne 'sqlite') {
      $envArgs += " --db_host=$DbHost --db_port=$DbPort --db_database=$DbDatabase --db_username=$DbUsername --db_password=`"$DbPassword`""
    }
    Sh "php artisan df:env $envArgs --no-interaction" $DfDir "php artisan df:env --db_connection=$DbConnection ... (credentials redacted)"
  }
  if ($LicenseKey -and -not (Select-String -Path "$DfDir\.env" -Pattern '^DF_LICENSE_KEY=' -Quiet)) {
    Add-Content "$DfDir\.env" "`nDF_LICENSE_KEY=$LicenseKey"; Log 'license key written to .env'
  }
  if (-not $AdminPassword) { throw 'AdminPassword is required for unattended df:setup' }
  Sh "php artisan df:setup --admin_first_name=$AdminFirst --admin_last_name=$AdminLast --admin_email=$AdminEmail --admin_password=`"$AdminPassword`" --admin_phone=`"$AdminPhone`" --no-interaction" $DfDir "php artisan df:setup --admin_email=$AdminEmail --admin_phone=$AdminPhone --admin_password=***"
  # df:setup swallows validation errors (e.g. missing phone) and exits 0, so prove the admin exists
  if ($DbConnection -eq 'sqlite') {
    $sq = ($DfDir -replace '\\','/') + '/database/database.sqlite'
    Set-Content "$Work\usercount.php" "<?php echo (new PDO('sqlite:$sq'))->query('select count(*) from user')->fetchColumn();" -Encoding ASCII
    $cnt = cmd /c "`"$PhpDir\php.exe`" `"$Work\usercount.php`" 2>&1"
    if ([int]$cnt -lt 1) { throw 'df:setup reported success but created no admin user; see its output above' }
    Log "admin users in system db: $cnt"
  }
  Sh 'php artisan config:clear' $DfDir
  Sh 'php artisan cache:clear' $DfDir
  MarkDone 'DreamFactory'
}

# ---------------------------------------------------------------- IIS
if ((Want 'Iis') -and -not (Done 'Iis')) {
  Log '== IIS: FastCGI, handler, verbs, site, ACLs'
  Import-Module WebAdministration
  $appcmd = "$env:windir\System32\inetsrv\appcmd.exe"
  $cgi = "$PhpDir\php-cgi.exe"

  $fc = Get-WebConfiguration -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/fastCgi/application[@fullPath='$cgi']"
  if (-not $fc) {
    & $appcmd set config /section:system.webServer/fastCgi "/+[fullPath='$cgi',arguments='',maxInstances='0',instanceMaxRequests='10000',activityTimeout='600',requestTimeout='600']" | Out-Null
    & $appcmd set config /section:system.webServer/fastCgi "/+[fullPath='$cgi'].environmentVariables.[name='PHP_FCGI_MAX_REQUESTS',value='10000']" | Out-Null
    & $appcmd set config /section:system.webServer/fastCgi "/+[fullPath='$cgi'].environmentVariables.[name='PHPRC',value='$PhpDir']" | Out-Null
    Log 'FastCGI application registered'
  }
  $h = Get-WebConfiguration -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/handlers/add[@name='PHP_via_FastCGI']"
  if (-not $h) {
    & $appcmd set config /section:system.webServer/handlers "/+[name='PHP_via_FastCGI',path='*.php',verb='*',modules='FastCgiModule',scriptProcessor='$cgi',resourceType='Either']" | Out-Null
    Log 'handler mapping PHP_via_FastCGI added'
  }
  foreach ($verb in 'GET','HEAD','POST','DELETE','PUT','PATCH','OPTIONS') {
    $ex = Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/security/requestFiltering/verbs/add[@verb='$verb']" -name allowed -ErrorAction SilentlyContinue
    if ($null -eq $ex) { Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/security/requestFiltering/verbs' -name '.' -value @{verb=$verb;allowed='true'} }
  }
  Log 'request filtering verbs allowed'

  if (Get-Website 'Default Web Site' -ErrorAction SilentlyContinue) { Stop-Website 'Default Web Site'; Set-ItemProperty 'IIS:\Sites\Default Web Site' serverAutoStart $false }
  if (-not (Test-Path "IIS:\AppPools\$SiteName")) {
    New-WebAppPool $SiteName | Out-Null
    Set-ItemProperty "IIS:\AppPools\$SiteName" managedRuntimeVersion ''      # No Managed Code
    Set-ItemProperty "IIS:\AppPools\$SiteName" processModel.idleTimeout ([TimeSpan]::Zero)
  }
  if (-not (Get-Website $SiteName -ErrorAction SilentlyContinue)) {
    New-Website -Name $SiteName -Port $SitePort -PhysicalPath "$DfDir\public" -ApplicationPool $SiteName | Out-Null
    Log "site $SiteName -> $DfDir\public :$SitePort"
  } elseif ((Get-Website $SiteName).physicalPath -ne "$DfDir\public") {
    Set-ItemProperty "IIS:\Sites\$SiteName" physicalPath "$DfDir\public"
    Log "site $SiteName repointed -> $DfDir\public"
  }
  # fastcgi.impersonate=1 makes PHP run as the site's anonymous user (IUSR by default). Point anonymous auth at the
  # app pool identity so IIS_IUSRS ACLs below apply. (The 2022 guide sidestepped this with "Connect As Administrator".)
  Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location $SiteName -filter 'system.webServer/security/authentication/anonymousAuthentication' -name userName -value ''
  Log 'anonymous auth -> application pool identity'
  # repo ships public/web.config with the rewrite rules + verbs, so no .htaccess import needed; but it does not set a
  # default document, so GET / is a 403.14 until index.php is added (the guide's "double check DefaultDocument" step)
  $dd = Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location $SiteName -filter "system.webServer/defaultDocument/files/add[@value='index.php']" -name value -ErrorAction SilentlyContinue
  if (-not $dd) { & $appcmd set config "$SiteName/" /section:defaultDocument "/+files.[value='index.php',@start]" /commit:apphost | Out-Null; Log 'default document index.php added' }
  # 'database' holds database.sqlite on DF 7 (not storage/databases as older guides say); sqlite needs dir write for journals
  foreach ($d in 'storage','public','bootstrap\cache','database') {
    & icacls "$DfDir\$d" /grant 'IIS_IUSRS:(OI)(CI)F' /T /Q | Out-Null
  }
  & icacls $DfDir /grant 'IIS_IUSRS:(OI)(CI)RX' /Q | Out-Null
  Log 'ACLs applied'
  & iisreset /noforce | Out-Null
  Start-Website $SiteName
  MarkDone 'Iis'
}

# ---------------------------------------------------------------- Verify
if (Want 'Verify') {
  Log '== Verify'
  RefreshPath
  Log "php:      $(cmd /c 'php -v 2>&1' | Select-Object -First 1)"
  Log "composer: $(cmd /c 'composer --version 2>&1' | Select-Object -First 1)"
  $av = cmd /c "cd /d `"$DfDir`" && php artisan --version 2>&1" | Where-Object { $_ -match 'Laravel' } | Select-Object -First 1
  Log "artisan:  $av"
  $pm = cmd /c 'php -m 2>&1'
  Log "sqlsrv: $($pm -contains 'sqlsrv') pdo_sqlsrv: $($pm -contains 'pdo_sqlsrv')"
  $base = "http://localhost:$SitePort"
  try { $root = Invoke-WebRequest "$base/" -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue; $rc = $root.StatusCode; $loc = $root.Headers.Location } catch { $rc = $_.Exception.Response.StatusCode.value__; $loc = $_.Exception.Response.Headers['Location'] }
  Log "GET / -> $rc $loc"
  if ($rc -ne 302 -and $rc -ne 200) { throw "GET / returned $rc; expected redirect to the admin UI (default document / rewrite problem)" }
  $r = Invoke-WebRequest "$base/api/v2/system/environment" -UseBasicParsing
  $j = $r.Content | ConvertFrom-Json
  Log "GET /api/v2/system/environment -> $($r.StatusCode); DF $($j.platform.version) php $($j.server.php_version)"
  if ($AdminPassword) {
    $body = @{ email = $AdminEmail; password = $AdminPassword } | ConvertTo-Json
    $s = Invoke-RestMethod -Method Post -Uri "$base/api/v2/system/admin/session" -ContentType 'application/json' -Body $body
    Log "admin login -> session_token present: $([bool]$s.session_token)"
    $hdr = @{ 'X-DreamFactory-Session-Token' = $s.session_token }
    $env2 = Invoke-RestMethod "$base/api/v2/system/environment" -Headers $hdr
    Log "license: $($env2.platform.license) ; is_hosted=$($env2.platform.is_hosted)"
    # PUT must reach PHP through IIS (the classic Windows failure is a 405 from request filtering)
    try { $pt = Invoke-WebRequest -Method Put -Uri "$base/api/v2/system/admin/session" -Headers $hdr -UseBasicParsing; $code = $pt.StatusCode }
    catch { $code = $_.Exception.Response.StatusCode.value__ }
    Log "PUT verb through IIS -> $code"
    if ($code -eq 405) { throw 'IIS blocked PUT (405): request filtering / handler verbs not applied' }
  }
  Log 'VERIFY OK'
}
Stop-Transcript | Out-Null
