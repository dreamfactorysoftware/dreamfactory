#!/usr/bin/env bash

# check whether whiptail or dialog is installed
# (choosing the first command found)
read dialog <<< "$(which whiptail dialog 2> /dev/null)"

##==============================================================================
## Environment Settings - should default to the config/xxx.php file values
##==============================================================================
declare -A settings=(
# Application
["APP_CIPHER"]="AES-256-CBC"
["APP_DEBUG"]="false"
["APP_ENV"]="production"
["APP_KEY"]=""
["APP_LOCALE"]="en"
["APP_LOG"]="single"
["APP_LOG_LEVEL"]="warning"
["APP_NAME"]="DreamFactory"
["APP_TIMEZONE"]="UTC"
["APP_URL"]="http://localhost"
["DF_LANDING_PAGE"]="/dreamfactory/dist/index.html"
# Database
["DB_CONNECTION"]="sqlite"
["DB_HOST"]=""
["DB_PORT"]=""
["DB_DATABASE"]="storage/databases/database.sqlite"
["DB_USERNAME"]=""
["DB_PASSWORD"]=""
["DB_CHARSET"]=""
["DB_COLLATION"]=""
["DF_SQLITE_STORAGE"]="storage/databases"
["DF_DB_MAX_RECORDS_RETURNED"]="1000"
["DF_FREETDS_SQLSRV"]="server/config/freetds/sqlsrv.conf"
["DF_FREETDS_SQLANYWHERE"]="server/config/freetds/sqlanywhere.conf"
["DF_FREETDS_SYBASE"]="server/config/freetds/sybase.conf"
["DF_FREETDS_DUMP"]="/tmp/freetds.log"
["DF_FREETDS_DUMPCONFIG"]="/tmp/freetdsconfig.log"
# File Storage
["DF_FILE_CHUNK_SIZE"]="10000000"
["DF_LOCAL_FILE_ROOT"]="app"
["DF_PACKAGE_PATH"]=""
# Cache
["CACHE_DRIVER"]="file"
["CACHE_PATH"]="storage/framework/cache/data"
["CACHE_PREFIX"]="dreamfactory"
["DF_CACHE_TTL"]="300"
# if CACHE_DRIVER=database
["CACHE_TABLE"]="cache"
# if CACHE_DRIVER=memcached
["MEMCACHED_HOST"]="127.0.0.1"
["MEMCACHED_PORT"]="11211"
["MEMCACHED_WEIGHT"]="100"
["MEMCACHED_PERSISTENT_ID"]=""
["MEMCACHED_USERNAME"]=""
["MEMCACHED_PASSWORD"]=""
# if CACHE_DRIVER=redis
["REDIS_HOST"]="127.0.0.1"
["REDIS_PORT"]="6379"
["REDIS_DATABASE"]=""
["REDIS_PASSWORD"]=""
# Queuing
["QUEUE_DRIVER"]="sync"
# Mail
["MAIL_DRIVER"]="smtp"
["MAIL_HOST"]=
["MAIL_PORT"]=
["MAIL_USERNAME"]=
["MAIL_PASSWORD"]=
["MAIL_ENCRYPTION"]=
["MAIL_FROM_ADDRESS"]="no-reply@dreamfactory.com"
["MAIL_FROM_NAME"]="DO NOT REPLY"
# Event Broadcasting
["BROADCAST_DRIVER"]="null"
["PUSHER_APP_ID"]=
["PUSHER_APP_KEY"]=
["PUSHER_APP_SECRET"]=
# Server-side Scripting
["DF_SCRIPTING_DISABLE"]=""
["DF_NODEJS_PATH"]="/usr/local/bin/node"
["DF_PYTHON_PATH"]="/usr/local/bin/python"
# API
["DF_API_ROUTE_PREFIX"]="api"
["DF_STATUS_ROUTE_PREFIX"]=""
["DF_STORAGE_ROUTE_PREFIX"]=""
["DF_XML_ROOT"]="dfapi"
["DF_ALWAYS_WRAP_RESOURCES"]="true"
["DF_RESOURCE_WRAPPER"]="resource"
["DF_CONTENT_TYPE"]="application/json"
# User Management
["DF_LOGIN_ATTRIBUTE"]="email"
["DF_CONFIRM_CODE_LENGTH"]="32"
["DF_CONFIRM_CODE_TTL"]="1440"
["JWT_SECRET"]=""
["DF_JWT_TTL"]="60"
["DF_JWT_REFRESH_TTL"]="20160"
["DF_ALLOW_FOREVER_SESSIONS"]="false"
["DF_CONFIRM_RESET_URL"]="'/dreamfactory/dist/#/reset-password'"
["DF_CONFIRM_INVITE_URL"]="'/dreamfactory/dist/#/user-invite'"
["DF_CONFIRM_ADMIN_INVITE_URL"]="'/dreamfactory/dist/#/admin-invite'"
["DF_CONFIRM_REGISTER_URL"]="'/dreamfactory/dist/#/register-confirm'"
# Limits
["LIMIT_CACHE_DRIVER"]="file"
# if LIMIT_CACHE_DRIVER=file
["LIMIT_CACHE_PATH"]="storage/framework/limit_cache"
# if LIMIT_CACHE_DRIVER=redis
["LIMIT_CACHE_REDIS_DATABASE"]="limit_cache"
["LIMIT_CACHE_REDIS_HOST"]="127.0.0.1"
["LIMIT_CACHE_REDIS_PORT"]="6379"
["LIMIT_CACHE_REDIS_PASSWORD"]=""
# Other settings
["DF_LOOKUP_MODIFIERS"]=""
["DF_INSTALL"]="GitHub"
)

declare -A settings_msg=(
# Application
["APP_CIPHER"]="If you are using an older installation of DreamFactory 2 and getting following error. 'No supported encrypter found. The cipher and / or key length are invalid' then please use rijndael-128 cipher. Using this cipher requires the php mcrypt extension to be installed."
["APP_DEBUG"]="When your application is in debug mode, detailed error messages with stack traces will be shown on every error that occurs within your application. If disabled, a simple generic error page is shown."
["APP_ENV"]="This may determine how various services behave in your application."
["APP_KEY"]="This key is used by the application for encryption and should be set to a random, 32 character string, otherwise these encrypted strings will not be safe. Use 'php artisan key:generate' to generate a new key. Please do this before deploying an application!"
["APP_LOCALE"]="The application locale determines the default locale that will be used by the translation service provider. Currently only 'en' (English) is supported."
["APP_LOG"]="This setting controls the placement and rotation of the log file used by the application."
["APP_LOG_LEVEL"]="The setting controls the amount and severity of the information logged by the application. This is hierarchical and goes in the following order: DEBUG -> INFO -> NOTICE -> WARNING -> ERROR -> CRITICAL -> ALERT -> EMERGENCY. If you set log level to WARNING then all WARNING, ERROR, CRITICAL, ALERT, and EMERGENCY will be logged. Setting log level to DEBUG will log everything. Default is WARNING."
['APP_NAME']="This value is used when the framework needs to place the application's name in a notification or any other location as required by the application or its packages."
["APP_TIMEZONE"]="Here you may specify the default timezone for your application, which will be used by the PHP date and date-time functions."
["APP_URL"]="This URL is used by the console to properly generate URLs when using the Artisan command line tool. You should set this to the root of your application so that it is used when running Artisan tasks."
["DF_LANDING_PAGE"]="This is the starting point (page, application, etc.) when a browser points to the server root URL."
# Database settings
["DB_CONNECTION"]="This corresponds to the driver that will be supporting connections to the system database server."
["DB_HOST"]="The hostname or IP address of the system database server."
["DB_PORT"]="The connection port for the host given, or blank if the provider default is used."
["DB_DATABASE"]="The database name to connect to and where to place the system tables."
["DB_USERNAME"]="Credentials for the system database connection if required."
["DB_PASSWORD"]="Credentials for the system database connection if required."
["DB_CHARSET"]="The character set override if required. Defaults use utf8, except utf8mb4 for MySQL-based databases - may cause problems for pre-5.7.7 (MySQL) or pre-10.2.2 (MariaDB), if so, use utf8."
["DB_COLLATION"]="The character set collation override if required. Defaults use utf8_unicode_ci, except utf8mb4_unicode_ci for MySQL-based database - may cause problems for pre-5.7.7 (MySQL) or pre-10.2.2 (MariaDB), if so, use utf8_unicode_ci."
["DF_DB_MAX_RECORDS_RETURNED"]="This is the default number of records to return at once for database queries."
["DF_SQLITE_STORAGE"]="This is the default location to store SQLite3 database files."
# FreeTDS configuration (Linux and OS X only)
["DF_FREETDS_SQLSRV"]="Location of SQL Server conf file"
["DF_FREETDS_SQLANYWHERE"]="Location of SAP/Sybase conf file"
["DF_FREETDS_SYBASE"]="Location of old Sybase conf file"
["DF_FREETDS_DUMP"]="Enabling and location of dump file, defaults to disabled or default freetds.conf setting"
["DF_FREETDS_DUMPCONFIG"]="Location of connection dump file, defaults to disabled"
# Storage
["DF_FILE_CHUNK_SIZE"]="File chunk size for downloadable files in bytes. Default is 10MB."
["DF_LOCAL_FILE_ROOT"]="The root folder for storing files for the local file service."
["DF_PACKAGE_PATH"]="Path to a package file, folder, or URL to import during instance launch."
# Cache
["CACHE_DRIVER"]="What type of driver or connection to use for cache storage."
["CACHE_PATH"]="The path to a folder where the cache files will be stored."
["DF_CACHE_TTL"]="Default cache time-to-live, defaults to 300."
["CACHE_TABLE"]="The database table name where cached information will be stored."
["CACHE_CONNECTION"]=""
["MEMCACHED_HOST"]="The hostname or IP address of the memcached server."
["MEMCACHED_PORT"]="The connection port for the host given, or blank if the provider default is used."
["MEMCACHED_USERNAME"]="Credentials for the memcached service if required."
["MEMCACHED_PASSWORD"]="Credentials for the memcached service if required."
["MEMCACHED_PERSISTENT_ID"]=""
["MEMCACHED_WEIGHT"]=""
# Queuing
["QUEUE_DRIVER"]="What type of driver or connection to use for queuing jobs on the server."
# Mail
["MAIL_DRIVER"]="What type of driver or connection to use for sending mail from the application."
["MAIL_HOST"]="The hostname or IP address of the mail server."
["MAIL_PORT"]="The connection port for the host given, or blank if the provider default is used."
["MAIL_USERNAME"]="Credentials for the mail service if required."
["MAIL_PASSWORD"]="Credentials for the mail service if required."
["MAIL_ENCRYPTION"]="The type of encryption used by the mail service, i.e. TLS or SSL."
["MAIL_FROM_ADDRESS"]="The default address to set in the 'from' field of an email."
["MAIL_FROM_NAME"]="The default name to set in the 'from' field of an email."
# Event Broadcasting
["BROADCAST_DRIVER"]=""
["PUSHER_APP_ID"]=
["PUSHER_APP_KEY"]=
["PUSHER_APP_SECRET"]=
# User Management
["DF_LOGIN_ATTRIBUTE"]="By default DreamFactory uses an email address for user authentication. You can change this to use username instead by setting this to 'username'."
["DF_CONFIRM_CODE_LENGTH"]="New user confirmation code length. Max/Default is 32. Minimum is 5."
["DF_CONFIRM_CODE_TTL"]="Confirmation code expiration. Default is 1440 minutes (24 hours)."
["DF_ALLOW_FOREVER_SESSIONS"]="false"
["JWT_SECRET"]="If a separate encryption salt is required for JSON Web Tokens, place it here. Defaults to the APP_KEY setting."
["DF_JWT_TTL"]="The time-to-live for JSON Web Tokens, i.e. how long each token will remain valid to use."
["DF_JWT_REFRESH_TTL"]="The time allowed in which a JSON Web Token can be refreshed from its origination."
["DF_CONFIRM_RESET_URL"]="Application path to where password resets are to be handled."
["DF_CONFIRM_INVITE_URL"]="Application path to where invited users are to be handled."
["DF_CONFIRM_ADMIN_INVITE_URL"]="Application path to where admin invites are to be handled."
["DF_CONFIRM_REGISTER_URL"]="Application path to where user registrations are to be handled."
# Server-side Scripting
["DF_SCRIPTING_DISABLE"]="To disable all server-side scripting set this to 'all', or comma-delimited list of v8js, nodejs, python, and/or php to disable individually."
["DF_NODEJS_PATH"]="The system will try to detect the executable path, but in some environments it is best to set the path to the installed Node.js executable."
["DF_PYTHON_PATH"]="The system will try to detect the executable path, but in some environments it is best to set the path to the installed Python executable"
# API
["DF_API_ROUTE_PREFIX"]="By default, API calls take the form of http://<server_name>/<api_route_prefix>/v<version_number>"
["DF_STATUS_ROUTE_PREFIX"]="By default, API calls take the form of http://<server_name>/[<status_route_prefix>/]status"
["DF_STORAGE_ROUTE_PREFIX"]="By default, API calls take the form of http://<server_name>/[<storage_route_prefix>/]<storage_service_name>/<file_path>"
["DF_XML_ROOT"]="XML root tag for HTTP responses."
["DF_ALWAYS_WRAP_RESOURCES"]="Most API calls return a resource array or a single resource, if array, do we wrap it?"
["DF_RESOURCE_WRAPPER"]="Most API calls return a resource array or a single resource, if array, what do we wrap it with?"
["DF_CONTENT_TYPE"]="Default content-type of response when accepts header is missing or empty."
# Limits
["LIMIT_CACHE_DRIVER"]="file"
["LIMIT_CACHE_PATH"]="Path to where limit tracking information will be stored."
["LIMIT_CACHE_REDIS_DATABASE"]="limit_cache"
["LIMIT_CACHE_REDIS_HOST"]="The hostname or IP address of the redis server."
["LIMIT_CACHE_REDIS_PORT"]="The connection port for the host given, or blank if the provider default is used."
["LIMIT_CACHE_REDIS_PASSWORD"]=""
# Other settings
["DF_LOOKUP_MODIFIERS"]="Lookup management, comma-delimited list of allowed lookup modifying functions like urlencode, trim, etc. Note: Setting this will disable a large list of modifiers already internally configured."
["DF_INSTALL"]="This designates from where or how this instance of the application was installed, i.e. Bitnami, GitHub, DockerHub, etc."
)

declare -A settings_options=(
# Application
["APP_DEBUG"]="true, false"
["APP_ENV"]="local, production"
["APP_LOCALE"]="en"
["APP_LOG"]="single, daily, syslog, errorlog"
["APP_LOG_LEVEL"]="debug, info, notice, warning, error, critical, alert, emergency"
# Database
["DB_CONNECTION"]="sqlite, mysql, pgsql, sqlsrv"
# Cache
["CACHE_DRIVER"]="apc, array, database, file, memcached, redis"
# Queuing
["QUEUE_DRIVER"]="sync, database, beanstalkd, sqs, redis, null"
# Mail
["MAIL_DRIVER"]="smtp, sendmail, mailgun, mandrill, ses, sparkpost, log, array"
["MAIL_ENCRYPTION"]=
# Event Broadcasting
["BROADCAST_DRIVER"]="pusher, redis, log, null"
# DreamFactory
["DF_LOGIN_ATTRIBUTE"]="email, username"
["DF_ALLOW_FOREVER_SESSIONS"]="true, false"
["DF_SCRIPTING_DISABLE"]="all or comma-delimited list of v8js, nodejs, python, and/or php"
["DF_ALWAYS_WRAP_RESOURCES"]="true, false"
# Limits
["LIMIT_CACHE_DRIVER"]="apc, array, database, file, memcached, redis"
)

declare -A features=(
# Auth features
["user"]="DreamFactory Native Users (via system database)"
["oauth_custom"]="Custom OAuth - locally configurable endpoints"
["oauth_bitbucket"]="OAuth for Bitbucket"
["oauth_facebook"]="OAuth for Facebook"
["oauth_github"]="OAuth for GitHub"
["oauth_google"]="OAuth for Google"
["oauth_linkedin"]="OAuth for LinkedIn"
["oauth_microsoft_live"]="OAuth for Microsoft Live"
["oauth_twitter"]="OAuth for Twitter"
["oauth_azure_ad"]="OAuth for Microsoft Azure Active Directory *"
["oidc"]="OpenID Connect *"
["ad"]="Microsoft Active Directory *"
["ldap"]="LDAP (Lightweight Directory Access Protocol) *"
["saml"]="SAML (Security Assertion Markup Language) *"
# Database features
["cassandra"]="Apache Cassandra"
["couchdb"]="Apache CouchDB"
["aws_dynamodb"]="AWS DynamoDB"
["aws_redshift_db"]="AWS Redshift DB"
["couchbase"]="Couchbase"
["firebird"]="Firebird SQL"
["ibmdb2"]="IBM DB2 *"
["sqlsrv"]="Microsoft SQL Server *"
["mongodb"]="MongoDB"
["mysql"]="MySQL, MariaDB, Percona, etc."
["pgsql"]="Postgre SQL"
["oracle"]="Oracle Database *"
["sqlanywhere"]="SAP SQL Anywhere *"
["sqlite"]="SQLite"
["salesforce_db"]="Salesforce (as a database service)"
# File features
["local_file"]="Local File Storage"
["aws_s3"]="AWS S3"
["azure_blob"]="Azure Blob Storage"
["openstack_object_storage"]="OpenStack Object Storage"
["rackspace_cloud_files"]="Rackspace Cloud Files"
# Email features
["local_email"]="Local Email"
["smtp_email"]="SMTP Email"
["mailgun_email"]="Mailgun Email"
["mandrill_email"]="Mandrill Email"
["aws_ses"]="AWS SES (Simple Email Service)"
# Script features
["v8js"]="V8 Javascript"
["nodejs"]="Node.js"
["php"]="PHP"
["python"]="Python"
# Cache features
["cache_local"]="Local cache"
["cache_memcached"]="Memcached"
["cache_redis"]="Redis"
# Notification features
["aws_sns"]="AWS SNS (Simple Notification System)"
["apn"]="Apple Push Notification *"
["gcm"]="Google GCM Notification *"
# Other features
["api_doc"]="API Docs using Open API (fka Swagger)"
["limits"]="API Limits *"
["logger"]="API Logging *"
["rws"]="HTTP Services"
["soap"]="SOAP-to-REST Services *"
)

declare -A feature_package_map=(
# Auth features
["user"]="df-user"
["oauth_custom"]="df-oauth"
["oauth_bitbucket"]="df-oauth"
["oauth_facebook"]="df-oauth"
["oauth_github"]="df-oauth"
["oauth_google"]="df-oauth"
["oauth_linkedin"]="df-oauth"
["oauth_microsoft_live"]="df-oauth"
["oauth_twitter"]="df-oauth"
["oauth_azure_ad"]="df-azure-ad"
["oidc"]="df-oidc"
["ad"]="df-adldap"
["ldap"]="df-adldap"
["saml"]="df-saml"
# Database features
["cassandra"]="df-cassandra"
["couchdb"]="df-couchdb"
["aws_dynamodb"]="df-aws"
["aws_redshift_db"]="df-aws"
["couchbase"]="df-couchbase"
["firebird"]="df-firebird"
["ibmdb2"]="df-ibmdb2"
["sqlsrv"]="df-sqlsrv"
["mongodb"]="df-mongodb"
["mysql"]="df-sqldb"
["pgsql"]="df-sqldb"
["oracle"]="df-oracledb"
["sqlanywhere"]="df-sqlanywhere"
["sqlite"]="df-sqldb"
["salesforce_db"]="df-salesforce"
# File features
["local_file"]="df-file"
["aws_s3"]="df-aws"
["azure_blob"]="df-azure"
["openstack_object_storage"]="df-rackspace"
["rackspace_cloud_files"]="df-rackspace"
# Email features
["local_email"]="df-email"
["smtp_email"]="df-email"
["mailgun_email"]="df-email"
["mandrill_email"]="df-email"
["aws_ses"]="df-aws"
# Script features
["v8js"]="df-script"
["nodejs"]="df-script"
["php"]="df-script"
["python"]="df-script"
# Cache features
["cache_local"]="df-cache"
["cache_memcached"]="df-cache"
["cache_redis"]="df-cache"
# Notification features
["aws_sns"]="df-aws"
["apn"]="df-notification"
["gcm"]="df-notification"
# Other features
["api_doc"]="df-apidoc"
["limits"]="df-limits"
["logger"]="df-logger"
["rws"]="df-rws"
["soap"]="df-soap"
)

# Applications
declare -A applications=(
["launchpad"]="DreamFactory Launchpad"
["admin"]="DreamFactory Administration"
["schema_mgr"]="Schema Manager"
["data_mgr"]="Data Manager"
["file_mgr"]="File Manager"
["api_doc"]="API Documentation and Testing"
)

declare -A app_package_map=(
["launchpad"]="df-admin-app"
["admin"]="df-admin-app"
["schema_mgr"]="df-admin-app"
["data_mgr"]="df-admin-app"
["file_mgr"]="df-filemanager-app"
["api_doc"]="df-swagger-ui"
)

# change tracking
declare -a chosen_features
declare -A chosen_settings
# menu control
declare -a menu_items

display_section() {
    textsize=${#1}
    width=80
    span=$((($width + $textsize) / 2))
    bar=$(printf '%.0s=' $(seq 1 $width))
    echo ""
    echo "${bar}"
    printf "||%${span}s\n" "$1"
    echo "${bar}"
    echo ""
}

display_title() {
    textsize=${#1}
    width=80
    span=$((($width + $textsize) / 2))
    bar=$(printf '%.0s-' $(seq 1 $width))
    echo ""
    echo "${bar}"
    printf "|%${span}s\n" "$1"
    echo "${bar}"
    echo ""
}

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

qtrim() {
    local var="$*"
    # remove leading quote characters
    var="${var#\"}"
    # remove trailing quote characters
    var="${var%\"}"
    echo -n "$var"
}

action_menu() {
    echo "$menu_msg"
    for i in ${!menu_items[@]}; do
        printf "%2d) %s\n" $((i+1)) "${menu_items[i]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

action_menu_handle() {
    msg=""
    prompt="What would you like to do? "
    while action_menu && read -e -p "$prompt" -n1 result; do
        if (( result > 0 && result <= ${#menu_items[@]} )); then
            break
        fi
        { msg="Invalid option: $result"; continue; }
    done
}

features_menu() {
    echo "$menu_msg"
    for i in ${!menu_items[@]}; do
        printf "%s %2d) %s\n" "${chosen_features[${menu_items[i]}]:- }" $((i+1)) "${features[${menu_items[i]}]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

features_menu_handle() {
    msg=""
    prompt="Select a number and ENTER to add (+) or remove () a feature, press ENTER when done: "
    while features_menu && read -e -p "$prompt" num && [[ "$num" ]]; do
        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
            ((num--));
            [[ "${chosen_features[${menu_items[num]}]}" ]] && chosen_features[${menu_items[num]}]="" || chosen_features[${menu_items[num]}]="+"
        else
            msg="Invalid option: $num"; continue;
        fi
    done
}

settings_menu() {
    echo "$menu_msg"
    for i in ${!menu_items[@]}; do
        printf "%2d) %s=%s\n" $((i+1)) "${menu_items[i]}" "${settings[${menu_items[i]}]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

settings_menu_handle() {
    msg=""
    prompt="Select a number and ENTER to edit a setting, or just ENTER to accept all settings as displayed: "
    while settings_menu && read -e -p "$prompt" num && [[ "$num" ]]; do
        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
            ((num--));
            name="${menu_items[num]}"
            [[ "${settings_msg[${name}]}" ]] && echo "${settings_msg[${name}]}"
            read -e -p "Change the value of ${name} to [${settings_options[${name}]}]: " -i "${settings[${name}]}" choice
            if [[ "${choice}" != "${settings[${name}]}" ]]; then
                settings["${name}"]="${choice}"
                chosen_settings["${name}"]="${choice}"
            fi
        else
            msg="Invalid option: $num"; continue;
        fi
    done
}

#-------------------------------------------
# Interactive portion
#-------------------------------------------
clear
# add preliminary helper text for what we are about to do
display_section "Welcome to the DreamFactory Installer"
echo "During this installation process, follow the prompts requesting various selections about the features and environment settings desired."


# Initialize variables
install_type="install"
env_source=".env-dist"
composer_source="composer.json-dist"

if [ -f ".env" ] || [ -f "composer.json" ] ; then
    display_title "Install or Upgrade"
    menu_msg="A previous installation has been detected."
    menu_items=(
    "Keep existing configuration"
    "Re-install from the defaults"
    "Cancel installation"
    )
    action_menu_handle
    case $result in
      1 ) [ -f ".env" ] && env_source=".env"
          [ -f "composer.json" ] && composer_source="composer.json"
          install_type="upgrade"
          ;;
      2 ) ;;
      3 ) exit;;
    esac
fi

mapfile -t env_lines < <(sed -e '/\s*#.*$/d' -e '/^\s*$/d' ${env_source})
for env_line in "${env_lines[@]}"; do
    env_key="${env_line%%=*}"
    env_val="${env_line#*=}"
    if [[ -n "${env_val}" && -n "${settings[${env_key}]+1}" ]]; then
        settings[${env_key}]="${env_val}"
    fi
done

mapfile -t composer_requires < <(awk '/"require":/{flag=1; next} /\}/{flag=0} flag' ${composer_source})
for composer_line in "${composer_requires[@]}"; do
    pkg=$(qtrim $(trim "${composer_line%%:*}"))
    if [ "dreamfactory" == "${pkg%%/*}" ]; then
        pkg="${pkg#*/}"
        for feature in "${!feature_package_map[@]}"; do
            [[ "${pkg}" == "${feature_package_map[${feature}]}" ]] && chosen_features["${feature}"]="+"
        done
    fi
done

display_section "Environment Settings"
menu_msg="The following menus allow you edit all of the allowed environment settings by section.
At the end of this script, the selections will be used to build/update the .env file.
To change any of these settings at a later time, either re-run this installation or edit the .env file manually."
menu_items=("Continue" "Skip this section (use defaults or existing settings)" "Cancel installation")
action_menu_handle
case $result in
    1 )
        display_title "Application Settings"
        menu_msg="Current application settings:"
        menu_items=(
        "APP_CIPHER"
        "APP_DEBUG"
        "APP_ENV"
        "APP_KEY"
        "APP_LOCALE"
        "APP_LOG"
        "APP_LOG_LEVEL"
        "APP_NAME"
        "APP_TIMEZONE"
        "APP_URL"
        "DF_LANDING_PAGE"
        )

        settings_menu_handle

        display_title "System Database settings"
        menu_msg="Which database connection type would you like to use for DreamFactory system tables?"
        menu_items=("SQLite (default)" "MySQL, MariaDB, Percona, etc." "Postgre SQL" "MS SQL Server")
        action_menu_handle
        menu_items=(
        "DB_HOST"
        "DB_PORT"
        "DB_DATABASE"
        "DB_USERNAME"
        "DB_PASSWORD"
        "DB_CHARSET"
        "DB_COLLATION"
        )
        case $result in
            1 ) chosen_features["sqlite"]="+"
                settings["DB_CONNECTION"]="sqlite"
                menu_items=("DB_DATABASE")
                [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="storage/databases/database.sqlite"
                ;;
            2 ) chosen_features["mysql"]="+"
                settings["DB_CONNECTION"]="mysql"
                [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="3306"
                ;;
            3 ) chosen_features["pgsql"]="+"
                settings["DB_CONNECTION"]="pgsql"
                [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="5432"
                ;;
            4 ) chosen_features["sqlsrv"]="+"
                settings["DB_CONNECTION"]="sqlsrv"
                [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="1433"
                ;;
        esac

        menu_msg="Current system database settings:"
        settings_menu_handle

        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "DF_SQLITE_STORAGE"
        "DF_DB_MAX_RECORDS_RETURNED"
        "DF_FREETDS_SQLSRV"
        "DF_FREETDS_SQLANYWHERE"
        "DF_FREETDS_SYBASE"
        "DF_FREETDS_DUMP"
        "DF_FREETDS_DUMPCONFIG"
        )
        settings_menu_handle

        display_title "System Cache Settings"
        menu_msg="Which driver would you like to use for DreamFactory system cache?"
        menu_items=("file (default)" "database" "memcached" "redis" "APC" "array (testing only)")
        action_menu_handle
        case $result in
            1 ) settings["CACHE_DRIVER"]="file"
                menu_items=("CACHE_PATH")
                [[ -z "${settings[CACHE_PATH]}" ]] && settings["CACHE_PATH"]="storage/framework/cache/data"
                ;;
            2 ) settings["CACHE_DRIVER"]="database"
                menu_items=("CACHE_TABLE")
                [[ -z "${settings[CACHE_TABLE]}" ]] && settings["CACHE_TABLE"]="cache"
                ;;
            3 ) chosen_features["memcached"]="+"
                settings["CACHE_DRIVER"]="memcached"
                menu_items=(
                "MEMCACHED_HOST"
                "MEMCACHED_PORT"
                "MEMCACHED_USERNAME"
                "MEMCACHED_PASSWORD"
                "MEMCACHED_PERSISTENT_ID"
                "MEMCACHED_WEIGHT"
                )
                ;;
            4 ) chosen_features["redis"]="+"
                settings["CACHE_DRIVER"]="redis"
                menu_items=(
                "REDIS_HOST"
                "REDIS_PORT"
                "REDIS_DATABASE"
                "REDIS_PASSWORD"
                )
                ;;
            5 ) chosen_features["apc"]="+"
                settings["CACHE_DRIVER"]="apc"
                menu_items=()
                ;;
            6 ) settings["CACHE_DRIVER"]="array"
                menu_items=()
                ;;
        esac
        menu_msg="Current system cache settings:"
        [[ -z "${menu_items[@]}" ]] && settings_menu_handle

        display_title "System Queuing Settings"
        menu_msg="Which driver would you like to use for DreamFactory system queuing?"
        menu_items=("sync (default - execute immediately), database, Beanstalkd, AWS Simple Queue Service, Redis, null (discards immediately - testing only")
        action_menu_handle
        case $result in
            1 ) settings["QUEUE_DRIVER"]="sync"
                menu_items=()
                ;;
            2 ) settings["QUEUE_DRIVER"]="database"
                menu_items=("QUEUE_TABLE")
                [[ -z "${settings[QUEUE_TABLE]}" ]] && settings["QUEUE_TABLE"]="jobs"
                ;;
            3 ) chosen_features["beanstalkd"]="+"
                settings["QUEUE_DRIVER"]="beanstalkd"
                menu_items=(
                "BEANSTALKD_HOST"
                )
                ;;
            4 ) chosen_features["aws_sqs"]="+"
                settings["QUEUE_DRIVER"]="sqs"
                menu_items=(
                "SQS_KEY"
                "SQS_SECRET"
                "SQS_REGION"
                "SQS_PREFIX"
                )
                ;;
            5 ) chosen_features["redis"]="+"
                settings["QUEUE_DRIVER"]="redis"
                menu_items=(
                "REDIS_HOST"
                "REDIS_PORT"
                "REDIS_DATABASE"
                "REDIS_PASSWORD"
                )
                ;;
            6 ) settings["QUEUE_DRIVER"]="null"
                menu_items=()
                ;;
        esac
        menu_msg="Current system queuing settings:"
        [[ -z "${menu_items[@]}" ]] && settings_menu_handle

        display_title "System File Storage Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "DF_FILE_CHUNK_SIZE"
        "DF_LOCAL_FILE_ROOT"
        "DF_PACKAGE_PATH"
        )
        settings_menu_handle

        display_title "System Queuing Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "DF_SQLITE_STORAGE"
        "DF_DB_MAX_RECORDS_RETURNED"
        "DF_FREETDS_SQLSRV"
        "DF_FREETDS_SQLANYWHERE"
        "DF_FREETDS_SYBASE"
        "DF_FREETDS_DUMP"
        "DF_FREETDS_DUMPCONFIG"
        )
        settings_menu_handle

        display_title "DreamFactory API Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "DF_API_ROUTE_PREFIX"
        "DF_STATUS_ROUTE_PREFIX"
        "DF_STORAGE_ROUTE_PREFIX"
        "DF_XML_ROOT"
        "DF_ALWAYS_WRAP_RESOURCES"
        "DF_RESOURCE_WRAPPER"
        "DF_CONTENT_TYPE"
        )
        settings_menu_handle

        display_title "Server-side Scripting Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "DF_SCRIPTING_DISABLE"
        "DF_NODEJS_PATH"
        "DF_PYTHON_PATH"
        )
        settings_menu_handle

        display_title "System Mail Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "MAIL_DRIVER"
        "MAIL_HOST"
        "MAIL_PORT"
        "MAIL_USERNAME"
        "MAIL_PASSWORD"
        "MAIL_ENCRYPTION"
        "MAIL_FROM_ADDRESS"
        "MAIL_FROM_NAME"
        )
        settings_menu_handle

        display_title "User Management Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "DF_LOGIN_ATTRIBUTE"
        "DF_CONFIRM_CODE_LENGTH"
        "DF_CONFIRM_CODE_TTL"
        "JWT_SECRET"
        "DF_JWT_TTL"
        "DF_JWT_REFRESH_TTL"
        "DF_ALLOW_FOREVER_SESSIONS"
        "DF_CONFIRM_RESET_URL"
        "DF_CONFIRM_INVITE_URL"
        "DF_CONFIRM_ADMIN_INVITE_URL"
        "DF_CONFIRM_REGISTER_URL"
        )
        settings_menu_handle

        display_title "Limits Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "LIMIT_CACHE_DRIVER"
        # if LIMIT_CACHE_DRIVER=file
        "LIMIT_CACHE_PATH"
        # if LIMIT_CACHE_DRIVER=redis
        "LIMIT_CACHE_REDIS_DATABASE"
        "LIMIT_CACHE_REDIS_HOST"
        "LIMIT_CACHE_REDIS_PORT"
        "LIMIT_CACHE_REDIS_PASSWORD"
        )
        settings_menu_handle

        display_title "Event Broadcasting Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "BROADCAST_DRIVER"
        "PUSHER_APP_ID"
        "PUSHER_APP_KEY"
        "PUSHER_APP_SECRET"
        )
        settings_menu_handle

        display_title "Other Settings"
        menu_msg="The following settings apply to all database services, not just the system database:"
        menu_items=(
        "DF_LOOKUP_MODIFIERS"
        "DF_INSTALL"
        )
        settings_menu_handle

        ;;
    2 ) ;;
    3 ) exit;;
esac

display_section "Feature Selections"
menu_msg="The following menus allow you select a list of desired features by section.
At the end of this script, the selections will be used to install and check for all required software and OS features.
To change any of these settings at a later time, re-run this installation."
menu_items=("Continue" "Skip this section (use the defaults or existing settings)" "Cancel installation")
action_menu_handle
case $result in
    1 )
        display_title "Authentication & Authorization"
        menu_msg="DreamFactory can always be authenticated against using the administrator accounts provisioned. Authentication and authorization can also be extended using the following optional features."
        menu_items=(
        "user"
        "oauth_custom"
        "oauth_bitbucket"
        "oauth_facebook"
        "oauth_github"
        "oauth_google"
        "oauth_linkedin"
        "oauth_microsoft_live"
        "oauth_twitter"
        "oauth_azure_ad"
        "oidc"
        "ad"
        "ldap"
        "saml"
        )

        features_menu_handle

        display_title "SQL & NoSQL Databases"
        menu_msg="DreamFactory supports connections to many database vendors. Choose the desired features to be supported on this install."
        menu_items=(
        "cassandra"
        "couchdb"
        "aws_dynamodb"
        "aws_redshift_db"
        "couchbase"
        "firebird"
        "ibmdb2"
        "sqlsrv"
        "mongodb"
        "mysql"
        "pgsql"
        "oracle"
        "sqlanywhere"
        "sqlite"
        "salesforce_db"
        )

        features_menu_handle

        display_title "File Storage Options"
        menu_msg="DreamFactory supports connections to many database vendors. Choose the desired features to be supported on this install:"
        menu_items=(
        "local_file"
        "aws_s3"
        "azure_blob"
        "openstack_object_storage"
        "rackspace_cloud_files"
        )

        features_menu_handle

        display_title "Email Services"
        menu_msg="DreamFactory supports connections to many email senders. Choose the desired features to be supported on this install:"
        menu_items=(
        "local_email"
        "smtp_email"
        "mailgun_email"
        "mandrill_email"
        "aws_ses"
        )

        features_menu_handle

        display_title "Server-side Scripting"
        menu_msg="DreamFactory supports several popular languages for server-side event scripting. Choose the desired features to be supported on this install:"
        menu_items=(
        "v8js"
        "nodejs"
        "php"
        "python"
        )

        features_menu_handle

        display_title "Non-System Caching Services"
        menu_msg="DreamFactory supports several popular languages for server-side event scripting. Choose the desired features to be supported on this install:"
        menu_items=(
        "cache_local"
        "cache_memcached"
        "cache_redis"
        )

        features_menu_handle

        display_title "Notification Services"
        menu_msg="DreamFactory supports several popular languages for server-side event scripting. Choose the desired features to be supported on this install:"
        menu_items=(
        "aws_sns"
        "apn"
        "gcm"
        )

        features_menu_handle

        display_title "Other Features"
        menu_msg="Choose the desired features to be supported on this install:"
        menu_items=(
        "api_doc"
        "limits"
        "logger"
        "rws"
        "soap"
        )

        features_menu_handle
        ;;
    2 ) ;;
    3 ) exit;;
esac

echo "Changes to make to environment:"
if [[ "${chosen_settings[@]}" ]] ; then
    if [ -f ".env" ] ; then
        # backup existing .env
        cp ".env" ".env-install-bkup"
        # if clean install, overwrite the existing .env
        [[ "install"="${install_type}" ]] && cp ".env-dist" ".env"
    else
        cp ".env-dist" ".env"
    fi
    for key in "${!chosen_settings[@]}"; do
        value="${chosen_settings[$key]}"
        to_find="${key}="
        to_replace="${key}=${value}"
        echo "${to_replace}"
        if grep -q "^${to_find}" ".env"; then
            sed -i'.tmp' "s/^$to_find.*/$to_replace/g" ".env"
        elif grep -q "^#${to_find}" ".env"; then
            sed -i'.tmp' "s/^#$to_find.*/$to_replace/g" ".env"
        else
            # append at end of file
            echo "{$to_replace}" >> ".env"
        fi
    done
else
    echo "None"
fi

echo "Features selected for this install:"
if [[ "${chosen_features[@]}" ]] ; then
    if [ -f "composer.json" ] ; then
        # backup existing composer.json
        cp "composer.json" "composer.json-install-bkup"
        # if clean install, overwrite the existing composer.json
        [[ "install"="${install_type}" ]] && cp "composer.json-dist" "composer.json"
    else
        cp "composer.json-dist" "composer.json"
    fi
    for K in "${!chosen_features[@]}"; do
        echo "${K}"
    done
else
    echo "None"
fi

exit

[[ "$dialog" ]] || {
    {
        for ((i = 0 ; i <= 100 ; i+=20)); do
            sleep 1
            echo $i
        done
    } | "$dialog" --gauge "Please wait while installing" 6 60 0
}

