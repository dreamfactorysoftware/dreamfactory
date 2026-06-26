#!/bin/bash

### INSTALLER FUNCTIONS

# We will use these to run each step of the installer inside run_process which will provide us with a
# progress bar while things are going.

MONGODB_PECL_VERSION="${MONGODB_PECL_VERSION:-2.3.0}"

system_update () {
  if ((CURRENT_OS == 7)); then
    timeout 180 yum makecache -y || true
  else
    # RHEL-family update repositories are often entitlement/media-dependent.
    # Refresh metadata when possible, but keep package installs as the hard gate.
    timeout 180 dnf makecache -y || true
  fi
}

install_system_dependencies () {
  if ((CURRENT_OS == 7)); then
    yum install -y git \
      curl \
      zip \
      unzip \
      ca-certificates \
      lsof \
      readline-devel \
      libzip-devel \
      wget \
      jq
  else
    dnf install -y dnf-plugins-core
    if ((CURRENT_OS >= 9)); then
      dnf config-manager --set-enabled crb || dnf config-manager --set-enabled "codeready-builder-for-rhel-${CURRENT_OS}-$(arch)-rpms" || dnf config-manager --set-enabled "ol${CURRENT_OS}_codeready_builder" || true
    fi
    #centos 8
    dnf install -y git \
      curl \
      zip \
      unzip \
      ca-certificates \
      lsof \
      readline-devel \
      wget \
      jq \
      policycoreutils-python-utils
    dnf install -y libzip-devel || dnf install -y libzip || true
  fi
  # Check installation status
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi
}

dnf_module_reset_php () {
  timeout 300 dnf -y module reset php || true
}

dnf_module_enable_remi_php85 () {
  timeout 300 dnf -y module enable php:remi-8.5
}

dnf_switch_to_remi_php85 () {
  dnf_module_reset_php
  dnf_module_enable_remi_php85
  timeout 300 dnf -y module switch-to php:remi-8.5 --allowerasing || true
}

install_remi_php85_packages () {
  dnf install -y --allowerasing php-common \
    php-xml \
    php-cli \
    php-curl \
    php-mysqlnd \
    php-sqlite3 \
    php-soap \
    php-mbstring \
    php-bcmath \
    php-devel \
    php-ldap \
    php-pgsql \
    php-pdo-firebird \
    php-pdo-dblib \
    php-gd \
    php-zip \
    php-opcache
}

assert_php85_active () {
  local php_bin
  local php_version

  hash -r 2>/dev/null || true
  php_bin=$(command -v php 2>/dev/null || true)
  if [[ -z "$php_bin" && -x /usr/bin/php ]]; then
    php_bin=/usr/bin/php
  fi
  if [[ -z "$php_bin" ]]; then
    sleep 5
    hash -r 2>/dev/null || true
    php_bin=$(command -v php 2>/dev/null || true)
    if [[ -z "$php_bin" && -x /usr/bin/php ]]; then
      php_bin=/usr/bin/php
    fi
  fi

  php_version=$("$php_bin" -r 'echo PHP_MAJOR_VERSION "." PHP_MINOR_VERSION;' 2>/dev/null || true)
  if [[ "$php_version" != "8.5" ]]; then
    echo_with_color red "\nExpected PHP 8.5 from Remi, but active php is ${php_version:-missing}. Continuing; later PHP-dependent steps will fail if PHP is unusable." >&5
  fi
}

install_remi_release_el9 () {
  local remi_release_rpm="http://rpms.remirepo.net/enterprise/remi-release-9.rpm"
  local os_minor

  os_minor=$(awk -F= '/^VERSION_ID=/{gsub(/"/, "", $2); split($2, version, "."); print version[2]}' /etc/os-release 2>/dev/null)

  if [[ -n "$os_minor" && "$os_minor" =~ ^[0-9]+$ && "$os_minor" -lt 4 ]]; then
    remi_release_rpm="https://rpms.remirepo.net/enterprise/9/remi/x86_64/remi-release-9.2-1.el9.remi.noarch.rpm"
  fi

  dnf install -y "$remi_release_rpm"
  sed -i 's/^repo_gpgcheck=1/repo_gpgcheck=0/' /etc/yum.repos.d/remi*.repo 2>/dev/null || true
}

assert_el9_php85_openssl_compatibility () {
  local os_pretty
  local libcrypto_path="/usr/lib64/libcrypto.so.3"

  if ((CURRENT_OS != 9)) || [[ "${DEFAULT_PHP_VERSION:-}" != "php8.5" ]]; then
    return 0
  fi

  os_pretty=$(awk -F= '/^PRETTY_NAME=/{gsub(/"/, "", $2); print $2}' /etc/os-release 2>/dev/null)

  if [[ -f "$libcrypto_path" ]] && grep -a -q "OPENSSL_3.2.0" "$libcrypto_path"; then
    return 0
  fi

  echo_with_color red "\n${os_pretty:-RHEL-compatible 9} does not provide OpenSSL 3.2 symbols required by Remi PHP 8.5." >&5
  echo_with_color red "Update to RHEL 9.6 or newer, or use the DreamFactory PHP 8.3 installer path for older RHEL/EUS systems." >&5
  return 1
}

install_php () {
  assert_el9_php85_openssl_compatibility || {
    kill $!
    exit 1
  }

  # Install the php repository
  if ((CURRENT_OS == 7)); then
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

    yum-config-manager --enable remi-php85

    #Install PHP
    yum --enablerepo=remi-php85 install -y php-common \
      php-xml \
      php-cli \
      php-curl \
      php-mysqlnd \
      php-sqlite3 \
      php-soap \
      php-mbstring \
      php-bcmath \
      php-devel \
      php-ldap \
      php-pgsql \
      php-pdo-dblib \
      php-gd \
      php-zip \
      php-opcache
  elif ((CURRENT_OS == 8)); then
    # RHEL 8
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-8.rpm

    dnf module list -y
    dnf_switch_to_remi_php85

    #Install PHP
    install_remi_php85_packages
  else
    # RHEL 9 / CentOS Stream 9
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
    install_remi_release_el9

    dnf_switch_to_remi_php85

    install_remi_php85_packages
  fi

  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi

  assert_php85_active
}

check_apache_installation_status () {
  ps aux | grep -v grep | grep httpd
  CHECK_APACHE_PROCESS=$?

  yum list installed | grep -E "^httpd.x86_64"
  CHECK_APACHE_INSTALLATION=$?
}

install_apache () {
  yum install -y httpd php
  if (($? >= 1)); then
    echo_with_color red "\nCould not install Apache. Exiting." >&5
    kill $!
    exit 1
  fi
  # Create apache2 site entry
  echo "
<VirtualHost *:80>
    DocumentRoot /opt/dreamfactory/public
    <Directory /opt/dreamfactory/public>
        AddOutputFilterByType DEFLATE text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript
        Options -Indexes +FollowSymLinks -MultiViews
        AllowOverride All
        AllowOverride None
        Require all granted
        RewriteEngine on
        RewriteBase /
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^.*$ /index.php [L]
        <LimitExcept GET HEAD PUT DELETE PATCH POST>
            Allow from all
        </LimitExcept>
        <Files web.config>
          Require all denied
        </Files>
    </Directory>
</VirtualHost>" >/etc/httpd/conf.d/dreamfactory.conf
}

restart_apache () {
  systemctl restart httpd.service
  systemctl enable httpd.service
  if command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --state >/dev/null 2>&1; then
    firewall-cmd --add-service=http
  fi
}

check_nginx_installation_status() {
  ps aux | grep -v grep | grep nginx
  CHECK_NGINX_PROCESS=$?

  yum list installed | grep -E "^nginx.x86_64"
  CHECK_NGINX_INSTALLATION=$?
}

install_nginx () {
  if ((CURRENT_OS == 7)); then
    yum --enablerepo=remi-php85 install -y php-fpm nginx
  else
    dnf install -y php-fpm nginx
  fi

  if (($? >= 1)); then
    echo_with_color red "\nCould not install Nginx. Exiting." >&5
    kill $!
    exit 1
  fi
  # Change php fpm configuration file
  sed -i 's/\;cgi\.fix\_pathinfo\=1/cgi\.fix\_pathinfo\=0/' $(php -i | sed -n '/^Loaded Configuration File => /{s:^.*> ::;p;}')
  # Create nginx site entry
  echo "
#Default API call rate -> Here is set to 1 per second, and is later defined in the location /api/v2 section
limit_req_zone \$binary_remote_addr zone=mylimit:10m rate=1r/s;
server {

  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;
  root /opt/dreamfactory/public;
  index index.php index.html index.htm;
  add_header X-Frame-Options \"SAMEORIGIN\";
  add_header X-XSS-Protection \"1; mode=block\";
  gzip on;
  gzip_disable \"msie6\";
  gzip_vary on;
  gzip_proxied any;
  gzip_comp_level 6;
  gzip_buffers 16 8k;
  gzip_http_version 1.1;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
  location / {

    try_files \$uri \$uri/ /index.php?\$args;
  }

  error_page 404 /404.html;
  error_page 500 502 503 504 /50x.html;

  location = /50x.html {

    root /usr/share/nginx/html;
  }
  location ~ \.php$ {

    try_files \$uri rewrite ^ /index.php?\$query_string;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
  }
  location ~ /\.ht {
    deny all;
  }
  location ~ /web.config {
    deny all;
  }
  #By default we will limit login calls here using the limit_req_zone set above. The below will allow 1 per second over
  # 5 seconds (so 5 in 5 seconds)from a single IP  before returning a 429 too many requests. Adjust as needed.
  location /api/v2/user/session {
    try_files \$uri \$uri/ /index.php?\$args;
    limit_req zone=mylimit burst=5 nodelay;
    limit_req_status 429;
  }
  location /api/v2/system/admin/session {
    try_files \$uri \$uri/ /index.php?\$args;
    limit_req zone=mylimit burst=5 nodelay;
    limit_req_status 429;
  }
}" >/etc/nginx/conf.d/dreamfactory.conf

  # RHEL 8/9 and CentOS Stream 8/9 default php-fpm to a unix socket rather than 127.0.0.1.
  if ((CURRENT_OS == 8 || CURRENT_OS == 9)); then
  sed -i "s,127.0.0.1:9000;,unix:/var/run/php-fpm/www.sock;," /etc/nginx/conf.d/dreamfactory.conf
  id -u nginx >/dev/null 2>&1 || useradd -r nginx
  fi

  #Need to remove default entry in nginx.conf
  grep default_server /etc/nginx/nginx.conf
  if (($? == 0)); then
    sed -i "s/default_server//g" /etc/nginx/nginx.conf
  fi
}

restart_nginx () {
  systemctl restart php-fpm.service nginx.service
  systemctl enable nginx.service && systemctl enable php-fpm.service
  if command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --state >/dev/null 2>&1; then
    firewall-cmd --add-service=http
  fi
}

install_php_pear () {
  if ((CURRENT_OS == 7)); then
    yum --enablerepo=remi-php85 install -y php-pear
  else
    dnf install -y php-pear
  fi

  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi

  timeout 30 pecl channel-update pecl.php.net || true
}

install_mcrypt () {
  local php_version_number
  php_version_number=$(php -r 'echo PHP_MAJOR_VERSION . PHP_MINOR_VERSION;' 2>/dev/null || true)
  if [[ "$php_version_number" == "85" ]]; then
    echo_with_color red "\nSkipping legacy mcrypt extension on PHP 8.5; no compatible PECL release is available." >&5
    return 0
  fi

  if ((CURRENT_OS == 7)); then
    yum --enablerepo=remi-php85 install -y libmcrypt-devel
  else
    dnf install -y libmcrypt-devel
  fi

  printf "\n" | pecl install mcrypt-1.0.9
  if (($? >= 1)); then
    echo_with_color red "\nMcrypt extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=mcrypt.so" >/etc/php.d/20-mcrypt.ini
  fix_php_extension_permissions mcrypt
}

install_mongodb () {
  if ((CURRENT_OS >= 8)); then
    dnf install -y php-pecl-mongodb2 || dnf install -y php-pecl-mongodb
    if (($? >= 1)); then
      echo_with_color red "\nMongo DB extension installation error." >&5
      kill $!
      exit 1
    fi
  elif ! pecl list | awk 'NR > 3 {print $1}' | grep -Fxq mongodb; then
    printf "\n\n\n\n\n\n\n\n\n\n\n" | pecl install "mongodb-${MONGODB_PECL_VERSION}"
    if (($? >= 1)); then
      echo_with_color red "\nMongo DB extension installation error." >&5
      kill $!
      exit 1
    fi
  fi
  if ! compgen -G "/etc/php.d/*mongodb*.ini" >/dev/null; then
    echo "extension=mongodb.so" >/etc/php.d/20-mongodb.ini
  fi
  fix_php_extension_permissions mongodb
}

install_sql_server () {
  if ((CURRENT_OS == 7)); then
    curl https://packages.microsoft.com/config/rhel/7/prod.repo >/etc/yum.repos.d/mssql-release.repo
    yum remove -y unixODBC-utf16 unixODBC-utf16-devel unixODBC-utf17 unixODBC-utf17-devel
    ACCEPT_EULA=Y yum install -y msodbcsql18 mssql-tools
  elif ((CURRENT_OS == 8)); then
    curl https://packages.microsoft.com/config/rhel/8/prod.repo >/etc/yum.repos.d/mssql-release.repo
    dnf remove -y unixODBC-utf16 unixODBC-utf16-devel unixODBC-utf17 unixODBC-utf17-devel
    ACCEPT_EULA=Y dnf install -y msodbcsql18 mssql-tools18 unixODBC-devel
  else
    curl https://packages.microsoft.com/config/rhel/9/prod.repo >/etc/yum.repos.d/mssql-release.repo
    dnf remove -y unixODBC-utf16 unixODBC-utf16-devel unixODBC-utf17 unixODBC-utf17-devel
    ACCEPT_EULA=Y dnf install -y msodbcsql18 mssql-tools18 unixODBC-devel
  fi
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
    kill $!
    exit 1
  fi

  if ((CURRENT_OS == 7)); then
    yum install -y unixODBC-devel-2.3.1
  elif ((CURRENT_OS == 8)); then
    dnf install -y unixODBC-devel-2.3.7
  else
    dnf install -y unixODBC-devel
  fi

  if ((CURRENT_OS >= 8)); then
    dnf install -y php-sqlsrv
    if (($? >= 1)); then
      echo_with_color red "\nMS SQL Server extension installation error." >&5
      kill $!
      exit 1
    fi
  elif ! pecl list | awk 'NR > 3 {print $1}' | grep -Fxq sqlsrv; then
    pecl install sqlsrv
    if (($? >= 1)); then
      echo_with_color red "\nMS SQL Server extension installation error." >&5
      kill $!
      exit 1
    fi
  fi
  if ! compgen -G "/etc/php.d/*sqlsrv*.ini" >/dev/null; then
    echo "extension=sqlsrv.so" >/etc/php.d/20-sqlsrv.ini
  fi
  fix_php_extension_permissions sqlsrv
}

install_pdo_sqlsrv () {
  if php -m | grep -Fxq pdo_sqlsrv; then
    return 0
  fi

  if ((CURRENT_OS >= 8)); then
    dnf install -y php-sqlsrv
    if (($? >= 1)); then
      echo_with_color red "\nMS SQL Server extension installation error." >&5
      kill $!
      exit 1
    fi
  elif ! pecl list | awk 'NR > 3 {print $1}' | grep -Fxq pdo_sqlsrv; then
    pecl install pdo_sqlsrv
    if (($? >= 1)); then
      echo_with_color red "\nMS SQL Server extension installation error." >&5
      kill $!
      exit 1
    fi
  fi
  if ! compgen -G "/etc/php.d/*pdo_sqlsrv*.ini" >/dev/null; then
    echo "extension=pdo_sqlsrv.so" >/etc/php.d/20-pdo_sqlsrv.ini
  fi
  fix_php_extension_permissions pdo_sqlsrv
}

install_oracle () {
  CLIENT_VERSION=$(ls -f $DRIVERS_PATH/oracle-instantclient*-*-[12][19].*.0.0.0*.x86_64.rpm | grep -oP '([1-9]+)\.([1-9]+)' | head -n 1)
  yum install -y libaio systemtap-sdt-devel $DRIVERS_PATH/oracle-instantclient*$CLIENT_VERSION*.x86_64.rpm
  if (($? >= 1)); then
    echo_with_color red "\nOracle instant client installation error" >&5
    kill $!
    exit 1
  fi
  # For instantclient versions that start with 21.* Oracle will create an index directory without suffix
  if [[ $CLIENT_VERSION == 21* ]]; then
    CLIENT_VERSION="21"
  fi
  echo "/usr/lib/oracle/$CLIENT_VERSION/client64/lib" >/etc/ld.so.conf.d/oracle-instantclient.conf
  ldconfig
  export PHP_DTRACE=yes
  printf "\n" | pecl install oci8-3.2.1
  if (($? >= 1)); then
    echo_with_color red "\nOracle instant client installation error" >&5
    kill $!
    exit 1
  fi
  echo "extension=oci8.so" >/etc/php.d/20-oci8.ini
}

install_db2 () {
  yum install -y ksh
  chmod +x /opt/dsdriver/installDSDriver
  /usr/bin/ksh /opt/dsdriver/installDSDriver
  ln -s /opt/dsdriver/include /include
  git clone https://github.com/php/pecl-database-pdo_ibm /opt/PDO_IBM
  cd /opt/PDO_IBM/ || exit 1
  phpize
  ./configure --with-pdo-ibm=/opt/dsdriver/
  make && make install
  if (($? >= 1)); then
    echo_with_color red "\nCould not make pdo_ibm extension." >&5
    kill $!
    exit 1
  fi
  echo "extension=pdo_ibm.so" >/etc/php.d/20-pdo_ibm.ini
}

install_db2_extension () {
  printf "/opt/dsdriver/ \n" | pecl install ibm_db2
  if (($? >= 1)); then
    echo_with_color red "\nibm_db2 extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=ibm_db2.so" >/etc/php.d/20-ibm_db2.ini
}

install_cassandra () {
  if((CURRENT_OS == 7)); then
    yum install -y gmp-devel openssl-devel cmake libuv-devel #boost cmake
  else
    dnf --enablerepo=powertools install -y libuv-devel
    dnf install -y gmp-devel openssl-devel cmake
  fi
  wget -c -P /opt/DataStax https://github.com/datastax/cpp-driver/archive/refs/tags/2.16.2.tar.gz
  cd /opt/DataStax
  tar -xf 2.16.2.tar.gz
  rm 2.16.2.tar.gz
  cd cpp-driver-2.16.2
  mkdir build && cd "$_"
  cmake ..
  make && make install
  if (($? >= 1)); then
    echo_with_color red "\ncassandra extension installation error." >&5
    kill $!
    exit 1
  fi
  export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig

  # Currently, we are using a specific version of the repository that is still functional, as
  # the recent efforts to enhance the installation process do not work properly.
  git clone --branch v1.3.x https://github.com/nano-interactive/ext-cassandra.git /opt/DataStax/ext-cassandra
  cd /opt/DataStax/ext-cassandra
  git checkout 1cf12c5ce49ed43a2c449bee4b7b23ce02a37bf0
  cd ./ext
  phpize
  cd ..
  mkdir build && cd "$_"
  ../ext/configure
  make && make install
  if (($? >= 1)); then
    echo_with_color red "\ncassandra extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=cassandra.so" >/etc/php.d/20-cassandra.ini
}

install_igbinary () {
  if ((CURRENT_OS >= 8)); then
    dnf install -y php-pecl-igbinary
    if (($? >= 1)); then
      echo_with_color red "\nigbinary extension installation error." >&5
      kill $!
      exit 1
    fi
  elif ! pecl list | awk 'NR > 3 {print $1}' | grep -Fxq igbinary; then
    pecl install igbinary
    if (($? >= 1)); then
      echo_with_color red "\nigbinary extension installation error." >&5
      kill $!
      exit 1
    fi
  fi
  if ! compgen -G "/etc/php.d/*igbinary*.ini" >/dev/null; then
    echo "extension=igbinary.so" >/etc/php.d/20-igbinary.ini
  fi
  fix_php_extension_permissions igbinary
}

install_python2 () {
  if ((CURRENT_OS == 7)); then
    yum install -y python python-pip
  else
    yum install -y python2 python2-pip
  fi
}

check_bunch_installation () {
  if ((CURRENT_OS == 7)); then
    pip list | grep bunch
  else
    pip2 list | grep bunch
  fi
}

install_bunch () {
  if ((CURRENT_OS == 7)); then
    pip install bunch
  else
    pip2 install bunch
  fi
}

install_python3 () {
  yum install -y python3 python3-pip
}

check_munch_installation () {
  python3 -c 'import munch' >/dev/null 2>&1
}

install_munch () {
  yum install -y python3-munch || python3 -m pip install --break-system-packages munch || python3 -m pip install munch
}

install_node () {
  # The df-mcp daemon needs Node 18+ (we ship 20.x LTS). RHEL/OL appstream tops out at
  # node 16, and the daemon's bundled dist uses import-attributes that 16 can't parse, so
  # reset the appstream module and install Node 20.x from NodeSource.
  dnf module reset -y nodejs 2>/dev/null || true
  curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
  dnf install -y --allowerasing nodejs
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi
  NODE_PATH=$(whereis node | cut -d" " -f2)
}

install_snowflake () {
  yum update -y
  yum install -y gcc cmake php-pdo php-devel
  # We need to use a previous version of the snowflake driver as the latest one seems to be bust.
  git clone https://github.com/snowflakedb/pdo_snowflake.git /src/snowflake
  cd /src/snowflake
  export PHP_HOME=/usr
  source /src/snowflake/scripts/build_pdo_snowflake.sh
  $PHP_HOME/bin/php -dextension=modules/pdo_snowflake.so -m | grep pdo_snowflake
  if (($? == 0)); then
    export PHP_HOME=/usr
    PHP_EXTENSION_DIR=$($PHP_HOME/bin/php -i | grep '^extension_dir' | sed 's/.*=>\(.*\).*/\1/')
    cp /src/snowflake/modules/pdo_snowflake.so $PHP_EXTENSION_DIR
    cp /src/snowflake/libsnowflakeclient/cacert.pem /etc/php.d
    if (($? >= 1)); then
      echo_with_color red "\npdo_snowflake driver installation error." >&5
      kill $!
      exit 1
    fi
    echo -e "extension=pdo_snowflake.so\n\npdo_snowflake.cacert=/etc/php.d/cacert.pem" >/etc/php.d/20-pdo_snowflake.ini
  else
    echo_with_color red "\nCould not build pdo_snowflake driver." >&5
    kill $!
    exit 1
  fi
}

install_hive_odbc () {
  yum update -y
  yum install -y php-odbc
  mkdir /opt/hive
  cd /opt/hive
  wget http://archive.mapr.com/tools/MapR-ODBC/MapR_Hive/MapRHive_odbc_2.6.1.1001/MapRHiveODBC-2.6.1.1001-1.x86_64.rpm
  rpm -ivh MapRHiveODBC-2.6.1.1001-1.x86_64.rpm
  test -f /opt/mapr/hiveodbc/lib/64/libmaprhiveodbc64.so
  rm MapRHiveODBC-2.6.1.1001-1.x86_64.rpm
  export HIVE_SERVER_ODBC_DRIVER_PATH=/opt/mapr/hiveodbc/lib/64/libmaprhiveodbc64.so
  HIVE_ODBC_INSTALLED=$(php -m | grep -E "^odbc" || true)
}

install_dremio_odbc () {
  yum update -y
  yum install -y php-odbc
  mkdir /opt/dremio
  cd /opt/dremio
  wget https://download.dremio.com/arrow-flight-sql-odbc-driver/arrow-flight-sql-odbc-driver-LATEST.x86_64.rpm
  RPM_FILE=$(ls arrow-flight-sql-odbc-driver-*.rpm)
  rpm -ivh "$RPM_FILE"
  rm -f "$RPM_FILE"
  test -f /opt/arrow-flight-sql-odbc-driver/lib64/libarrow-odbc.so.0.9.1.168
  export DREMIO_SERVER_ODBC_DRIVER_PATH=/opt/arrow-flight-sql-odbc-driver/lib64//libarrow-odbc.so.0.9.1.168
  DREMIO_ODBC_INSTALLED=$(php -m | grep -E "^odbc" || true)
}

install_databricks_odbc () {
  yum update -y
  yum install -y php-odbc
  mkdir /opt/databricks
  cd /opt/databricks
  wget https://databricks-bi-artifacts.s3.us-east-2.amazonaws.com/simbaspark-drivers/odbc/2.8.2/SimbaSparkODBC-2.8.2.1013-LinuxRPM-64bit.zip
  unzip -q SimbaSparkODBC-2.8.2.1013-LinuxRPM-64bit.zip
  rm -f SimbaSparkODBC-2.8.2.1013-LinuxRPM-64bit.zip
  rm -rf docs/
  rpm -ivh simbaspark-2.8.2.1013-1.x86_64.rpm
  test -f /opt/simba/spark/lib/64/libsparkodbc_sb64.so
  rm simbaspark-2.8.2.1013-1.x86_64.rpm
  export DATABRICKS_SERVER_ODBC_DRIVER_PATH=/opt/simba/spark/lib/64/libsparkodbc_sb64.so
  DATABRICKS_ODBC_INSTALLED=$(php -m | grep -E "^odbc" || true)
}

install_hana_odbc () {
  # TODO: Implement SAP HANA ODBC driver installation for CentOS/RHEL
  echo_with_color red "\nSAP HANA ODBC driver installation is not yet implemented for CentOS/RHEL." >&5
  kill $!
  exit 1
}

enable_opcache () {
  local opcache_module_dir
  opcache_module_dir=$(php-config --extension-dir 2>/dev/null || true)
  {
    if [[ -f "${opcache_module_dir}/opcache.so" || -f /usr/lib64/php/modules/opcache.so ]]; then
      echo 'zend_extension=opcache.so'
    fi
    echo 'opcache.enable=1'
    echo 'opcache.memory_consumption=192'
    echo 'opcache.interned_strings_buffer=16'
    echo 'opcache.max_accelerated_files=16229;'
    echo 'opcache.max_wasted_percentage=15'
    echo 'opcache.validate_timestamps=0'
  } > /etc/php.d/10-opcache.ini
}

install_composer () {
  # RHEL/CentOS/Oracle Linux pull composer in from EPEL as a dependency, so a
  # working composer is usually already on PATH. Use it rather than re-bootstrapping
  # from getcomposer.org (the manual bootstrap is fragile under a minimal env).
  if command -v composer >/dev/null 2>&1; then
    echo_with_color green "    Composer already present ($(composer --version 2>/dev/null | head -1))\n" >&5
    return 0
  fi
  rm -f /tmp/composer-setup.php
  if ! curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php; then
    echo_with_color red "\n${ERROR_STRING}" >&5
    exit 1
  fi
  php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    exit 1
  fi
}

check_mysql_exists () {
  yum list installed | grep -E "mariadb-server.x86_64"
  CHECK_MYSQL_INSTALLATION=$?

  ps aux | grep -v grep | grep -E "^mysql"
  CHECK_MYSQL_PROCESS=$?

  lsof -i :3306 | grep LISTEN
  CHECK_MYSQL_PORT=$?
}

install_mariadb () {
  yum install -y mariadb-server
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi

  systemctl start mariadb || service mariadb start
  if (($? >= 1)); then
    echo_with_color red "\nCould not start MariaDB.. Exit " >&5
    kill $!
    exit 1
  fi
  systemctl enable mariadb
  mysqladmin -u root -h localhost password "${DB_PASS}" || true
}

clone_dreamfactory_repository () {
  mkdir -p /opt/dreamfactory
  if [[ -z "${DREAMFACTORY_VERSION_TAG}" ]]; then
    git clone -b master --single-branch https://github.com/dreamfactorysoftware/dreamfactory.git /opt/dreamfactory
  else
    git clone -b "${DREAMFACTORY_VERSION_TAG}" --single-branch https://github.com/dreamfactorysoftware/dreamfactory.git /opt/dreamfactory
  fi
  if (($? >= 1)); then
    echo_with_color red "\nCould not clone DreamFactory repository. Exiting. " >&5
    kill $!
    exit 1
  fi
  DF_CLEAN_INSTALLATION=TRUE
}

run_composer_install () {
  # If Oracle is not installed, add the --ignore-platform-reqs option
  # to composer command
  if [[ $ORACLE == TRUE ]]; then
    if [[ $CURRENT_USER == "root" ]]; then
      sudo -u "$CURRENT_USER" COMPOSER_ALLOW_SUPERUSER=1 bash -c "composer install --no-dev"
    else
      sudo -u "$CURRENT_USER" bash -c "composer install --no-dev"
    fi
  else
    if [[ $CURRENT_USER == "root" ]]; then
      sudo -u "$CURRENT_USER" COMPOSER_ALLOW_SUPERUSER=1 bash -c "composer install --no-dev --ignore-platform-reqs"
    else
      sudo -u "$CURRENT_USER" bash -c "composer install --no-dev --ignore-platform-reqs"
    fi
  fi
}

# Define common constants
DF_FOLDER="/opt/dreamfactory"
DESTINATION_FOLDER="$DF_FOLDER/public"

run_commercial_upgrade () {
  echo_with_color magenta "\nEnter absolute path to license files, complete with trailing slash: [/]" >&5
  read -r LICENSE_PATH

  if [[ -z $LICENSE_PATH ]]; then
    LICENSE_PATH="."
  fi

  ls $LICENSE_PATH/composer.{json,lock,json-dist}

  if (($? >= 1)); then
    echo_with_color red "\nLicenses not found. Exiting!" >&5
    kill $!
    exit 1
  else
    cp $LICENSE_PATH/composer.{json,lock,json-dist} /opt/dreamfactory/
    echo -e "\nLicense files installed. \n" >&5
    echo -e "Upgrading DreamFactory to %s...\n" "$latest_tag" >&5
  fi
}

run_open_source_upgrade () {
  # pull the latest tag from the repo
  git pull origin "$latest_tag"
}

run_artisan_commands () {
  bash -c "php artisan migrate --seed"
  bash -c "php artisan optimize:clear"
}

# Function to upgrade DreamFactory
upgrade_dreamfactory () {
  # Define constants
  DF_FOLDER="/opt/dreamfactory"  # DF folder

  # Go to the DF folder
  cd "$DF_FOLDER" || exit

  folder_info=$(ls -ld "$DF_FOLDER")

  # Extract the owner and group using text processing
  owner=$(echo "$folder_info" | awk '{print $3}')
  group=$(echo "$folder_info" | awk '{print $4}')

  # Go to the DF folder
  cd "$DF_FOLDER" || exit

  # Check for the latest tag on the DF git repo
  latest_tag=$(git ls-remote --tags origin | grep -Eo 'refs/tags/[0-9]+\.[0-9]+\.[0-9]+$' | sort -r | head -n 1 | cut -d "/" -f 3)

  # Get the current version of the installed DF instance
  # Read the app.php file in the config folder and get the version
  current_version=$(grep -Eo 'version.*[0-9]+\.[0-9]+\.[0-9]+' config/app.php | cut -d "'" -f 3)

  # Check if the current version is less than 5.0.0
  if [[ "$current_version" < "5.0.0" ]]; then
    echo_with_color red "DreamFactory version is less than 5.0.0. Please upgrade to v5 first or contact DreamFactory support." >&5
    kill $!
    exit 1
  fi

  # Compare the current version with the latest tag
  if [[ "$current_version" == "$latest_tag" ]]; then
    echo_with_color red "DreamFactory is already up to date." >&5
    kill $!
    exit 1
  fi

  # Check if the current version is greater than the latest tag (this should not happen but we check anyway)
  if [[ "$current_version" > "$latest_tag" ]]; then
    echo_with_color red "Installed DreamFactory version is greater than the published version. Please contact DreamFactory support." >&5
    kill $!
    exit 1
  fi

  # Check if there are uncommitted changes
  if ! git diff --quiet HEAD -- "$DESTINATION_FOLDER"; then
    echo_with_color red "There are uncommitted changes in the repository. Please clean the installation folder before upgrading." >&5
    kill $1
    exit 1
  fi

  # Ask if the DF instance is commercial or not
  echo_with_color magenta "Is this a commercial DreamFactory instance? [Yy/Nn] " >&5
  read -r LICENSE_FILE_ANSWER

  if [[ -z $LICENSE_FILE_ANSWER ]]; then
    LICENSE_FILE_ANSWER=N
  fi

  if [[ $LICENSE_FILE_ANSWER =~ ^[Yy]$ ]]; then
    echo -e "  Upgrading commercial version\n" >&5
    run_commercial_upgrade
  else
    echo -e "  Upgrading open source version\n" >&5
    run_open_source_upgrade
  fi

  # Install the composer files
  echo -e "   Updating DreamFactory\n" >&5
  run_composer_install

  # Call artisan commands
  echo -e "   Running artisan commands\n" >&5
  run_artisan_commands

  # Change ownership to current user
  chown -R $owner:$group /opt/dreamfactory
}

install_simba_trino_odbc () {
  if [[ -z "$SIMBA_TRINO_DRIVER_PATH" || ! -f "$SIMBA_TRINO_DRIVER_PATH" ]]; then
    echo_with_color red "Simba Trino ODBC driver file not found." >&5
    exit 1
  fi
  if [[ "$SIMBA_TRINO_DRIVER_PATH" == *.rpm ]]; then
    rpm -ivh "$SIMBA_TRINO_DRIVER_PATH"
  elif [[ "$SIMBA_TRINO_DRIVER_PATH" == *.deb ]]; then
    if command -v alien >/dev/null 2>&1; then
      alien --to-rpm "$SIMBA_TRINO_DRIVER_PATH"
      RPM_FILE=$(ls simbatrino*.rpm | head -n 1)
      if [[ -f "$RPM_FILE" ]]; then
        rpm -ivh "$RPM_FILE"
      else
        echo_with_color red "Failed to convert DEB to RPM." >&5
        exit 1
      fi
    else
      echo_with_color red "alien not installed. Cannot convert DEB to RPM." >&5
      exit 1
    fi
  else
    echo_with_color red "Unsupported file type for Simba Trino ODBC driver." >&5
    exit 1
  fi

  mkdir -p /opt/simba/trinoodbc/lib/64/
  cp "$SIMBA_TRINO_LICENSE_PATH" /opt/simba/trinoodbc/lib/64/ || echo_with_color red "Failed to copy license file." >&5
  
  echo_with_color green "Simba Trino ODBC driver installation complete." >&5
}
