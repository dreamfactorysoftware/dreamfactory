#!/usr/bin/env bash

# make sure we have BASH 4 or greater
if (( ${BASH_VERSION%%.*} < 4 )); then
    echo "This installer requires a BASH version of 4.0 or greater. You have version ${BASH_VERSION}."
    if [[ "OSX" == os_type ]]; then
        echo "Try 'brew install bash' and then restart the terminal"
    fi
    exit
fi

##==============================================================================
## Environment Settings - should default to the config/xxx.php file values
##==============================================================================
declare -a settings_groups=(
"Application Settings"
"Database Settings"
"Caching Settings"
"Queuing Settings"
"Email Settings"
"API Settings"
"Scripting Settings"
"Broadcasting Settings"
"Other Settings"
)

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
["DB_MAX_RECORDS_RETURNED"]="1000"
["DF_SQLITE_STORAGE"]="storage/databases"
["DF_FREETDS_DUMP"]="/tmp/freetds.log"
["DF_FREETDS_DUMPCONFIG"]="/tmp/freetdsconfig.log"
# File Storage
["DF_FILE_CHUNK_SIZE"]="10000000"
# Cache
["CACHE_DRIVER"]="file"
["CACHE_PATH"]="storage/framework/cache/data"
["CACHE_PREFIX"]="dreamfactory"
["CACHE_DEFAULT_TTL"]="300"
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
["QUEUE_TABLE"]="jobs"
["QUEUE_NAME"]="default"
["QUEUE_RETRY_AFTER"]="90"
# if QUEUE_DRIVER=beanstalkd
["QUEUE_HOST"]="localhost"
# if QUEUE_DRIVER=redis
["QUEUE_HOST"]=""
["QUEUE_PORT"]=""
["QUEUE_DATABASE"]=""
["QUEUE_PASSWORD"]=""
# if QUEUE_DRIVER=sqs
["SQS_KEY"]=""
["SQS_SECRET"]=""
["SQS_REGION"]="us-east-1"
["SQS_PREFIX"]="https://sqs.us-east-1.amazonaws.com/your-account-id"
# Event Broadcasting
["BROADCAST_DRIVER"]="null"
["PUSHER_APP_ID"]=
["PUSHER_APP_KEY"]=
["PUSHER_APP_SECRET"]=
# if BROADCAST_DRIVER=redis
["BROADCAST_HOST"]=""
["BROADCAST_PORT"]=""
["BROADCAST_DATABASE"]=""
["BROADCAST_PASSWORD"]=""
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
["DF_PACKAGE_PATH"]=""
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
["DB_MAX_RECORDS_RETURNED"]="This is the default number of records to return at once for database queries."
["DF_SQLITE_STORAGE"]="This is the default location to store SQLite3 database files."
# FreeTDS configuration (Linux and OS X only)
["DF_FREETDS_DUMP"]="Enabling and location of dump file, defaults to disabled or default freetds.conf setting"
["DF_FREETDS_DUMPCONFIG"]="Location of connection dump file, defaults to disabled"
# Storage
["DF_FILE_CHUNK_SIZE"]="File chunk size for downloadable files in bytes. Default is 10MB."
# Cache
["CACHE_DRIVER"]="What type of driver or connection to use for cache storage."
["CACHE_PATH"]="The path to a folder where the cache files will be stored."
["CACHE_DEFAULT_TTL"]="Default cache time-to-live, defaults to 300."
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
["LIMIT_CACHE_DRIVER"]="What type of driver or connection to use for limit cache storage."
["LIMIT_CACHE_PATH"]="Path to where limit tracking information will be stored."
["LIMIT_CACHE_REDIS_DATABASE"]="limit_cache"
["LIMIT_CACHE_REDIS_HOST"]="The hostname or IP address of the redis server."
["LIMIT_CACHE_REDIS_PORT"]="The connection port for the host given, or blank if the provider default is used."
["LIMIT_CACHE_REDIS_PASSWORD"]=""
# Other settings
["DF_PACKAGE_PATH"]="Path to a package file, folder, or URL to import during instance launch."
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

declare -a feature_groups=(
"Authentication & Authorization Services"
"Caching Services"
"Database Services (SQL & NoSQL)"
"Email Services"
"File Storage Services"
"Notification Services"
"Server-side Scripting"
"UI Applications"
"Other Features and Services"
)

declare -A features_in_groups=(
["Authentication & Authorization Services"]="user oauth_custom oauth_bitbucket oauth_facebook oauth_github oauth_google oauth_linkedin oauth_microsoft_live oauth_twitter oauth_azure_ad oidc ad ldap saml"
["Database Services (SQL & NoSQL)"]="cassandra couchdb aws_dynamodb aws_redshift_db couchbase firebird ibmdb2 sqlsrv mongodb mysql pgsql oracle sqlanywhere sqlite salesforce_db"
["Caching Services"]="cache_apc cache_database cache_file cache_memcached cache_redis"
["Email Services"]="command_email smtp_email mailgun_email mandrill_email sparkpost_email aws_ses"
["File Storage Services"]="local_file aws_s3 azure_blob openstack_object_storage rackspace_cloud_files"
["Notification Services"]="aws_sns apn gcm"
["Server-side Scripting"]="v8js nodejs php python"
["UI Applications"]="launchpad admin schema_mgr data_mgr file_mgr api_doc_ui"
["Other Features and Services"]="api_doc limits logger rws soap"
)

declare -A feature_group_prompts=(
["Authentication & Authorization Services"]="DreamFactory can always be authenticated against using the administrator accounts provisioned. Authentication and authorization can also be extended using the following optional features."
["Database Services (SQL & NoSQL)"]="DreamFactory supports connections to many database vendors. Choose the desired features to be supported on this install."
["Caching Services"]="DreamFactory supports several popular stores for server-side caching. Choose the desired features to be supported on this install:"
["Email Services"]="DreamFactory supports connections to many email senders. Choose the desired features to be supported on this install:"
["File Storage Services"]="DreamFactory supports several popular storage options for files. Choose the desired features to be supported on this install:"
["Notification Services"]="DreamFactory supports several popular languages for server-side scripting. Choose the desired features to be supported on this install:"
["Server-side Scripting"]="DreamFactory supports several popular notification services. Choose the desired features to be supported on this install:"
["UI Applications"]="Choose the desired UI components to be loaded on this server:"
["Other Features and Services"]="Choose the desired features to be supported on this install:"
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
["oauth_azure_ad"]="OAuth for Microsoft Azure Active Directory"
["oidc"]="OpenID Connect"
["ad"]="Microsoft Active Directory"
["ldap"]="LDAP (Lightweight Directory Access Protocol)"
["saml"]="SAML (Security Assertion Markup Language)"
# Database features
["aws_dynamodb"]="AWS DynamoDB"
["aws_redshift_db"]="AWS Redshift DB"
["azure_documentdb"]="Azure Tables"
["azure_table"]="Azure Tables"
["cassandra"]="Apache Cassandra"
["couchdb"]="Apache CouchDB"
["couchbase"]="Couchbase"
["firebird"]="Firebird SQL"
["ibmdb2"]="IBM DB2"
["sqlsrv"]="Microsoft SQL Server"
["mongodb"]="MongoDB"
["mysql"]="MySQL, MariaDB, Percona, etc."
["pgsql"]="Postgre SQL"
["oracle"]="Oracle Database"
["sqlanywhere"]="SAP SQL Anywhere"
["sqlite"]="SQLite"
["salesforce_db"]="Salesforce (as a database service)"
# File features
["local_file"]="Local File Storage"
["aws_s3"]="AWS S3"
["azure_blob"]="Azure Blob Storage"
["openstack_object_storage"]="OpenStack Object Storage"
["rackspace_cloud_files"]="Rackspace Cloud Files"
# Email features
["command_email"]="Email sent by server command (sendmail)"
["smtp_email"]="SMTP Email"
["mailgun_email"]="Mailgun Email"
["mandrill_email"]="Mandrill Email"
["sparkpost_email"]="SparkPost Email"
["aws_ses"]="AWS SES (Simple Email Service)"
# Script features
["v8js"]="V8 Javascript Scripting"
["nodejs"]="Node.js Scripting"
["php"]="PHP Scripting"
["python"]="Python Scripting"
# Cache features
["cache_apc"]="APC as Cache"
["cache_database"]="Database as Cache"
["cache_file"]="File-based Cache"
["cache_memcached"]="Memcached"
["cache_redis"]="Redis"
# Notification features
["aws_sns"]="AWS SNS (Simple Notification System)"
["apn"]="Apple Push Notification"
["gcm"]="Google GCM Notification"
# UI Applications
["launchpad"]="DreamFactory Launchpad App"
["admin"]="DreamFactory Administration App"
["schema_mgr"]="Schema Manager App"
["data_mgr"]="Data Manager App"
["file_mgr"]="File Manager App"
["api_doc_ui"]="API Documentation and Testing App"
# Other features
["api_doc"]="API Docs using Open API (fka Swagger)"
["limits"]="API Limits"
["logger"]="API Logging"
["rws"]="HTTP Services"
["soap"]="SOAP-to-REST Services"
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
["aws_dynamodb"]="df-aws"
["aws_redshift_db"]="df-aws"
["azure_documentdb"]="df-azure"
["azure_table"]="df-azure"
["cassandra"]="df-cassandra"
["couchdb"]="df-couchdb"
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
["command_email"]="df-email"
["smtp_email"]="df-email"
["mailgun_email"]="df-email"
["mandrill_email"]="df-email"
["sparkpost_email"]="df-email"
["aws_ses"]="df-aws"
# Script features
["v8js"]="df-script"
["nodejs"]="df-script"
["php"]="df-script"
["python"]="df-script"
# Cache features
["cache_apc"]="df-cache"
["cache_database"]="df-cache"
["cache_file"]="df-cache"
["cache_memcached"]="df-cache"
["cache_redis"]="df-cache"
# Notification features
["aws_sns"]="df-aws"
["apn"]="df-notification"
["gcm"]="df-notification"
# UI Applications
["launchpad"]="df-admin-app"
["admin"]="df-admin-app"
["schema_mgr"]="df-admin-app"
["data_mgr"]="df-admin-app"
["file_mgr"]="df-filemanager-app"
["api_doc_ui"]="df-swagger-ui"
# Other features
["api_doc"]="df-apidoc"
["limits"]="df-limits"
["logger"]="df-logger"
["rws"]="df-rws"
["soap"]="df-soap"
)

declare -A feature_extension_map=(
# Auth features
["ad"]="ldap"
["ldap"]="ldap"
# Database features
["aws_redshift_db"]="pdo_pgsql"
["cassandra"]="cassandra"
["couchbase"]="couchbase"
["firebird"]="pdo_firebird"
["ibmdb2"]="pdo_ibm"
["sqlsrv"]="pdo_sqlsrv"
["mongodb"]="mongodb"
["mysql"]="pdo_mysql"
["pgsql"]="pdo_pgsql"
["oracle"]="oci8"
["sqlanywhere"]="pdo_dblib"
["sqlite"]="pdo_sqlite"
# Script features
["v8js"]="v8js"
# Cache features
["cache_apc"]="apc"
["cache_memcached"]="memcached"
["cache_redis"]="redis"
# Notification features
["apn"]="curl"
["gcm"]="curl"
# Other features
["rws"]="curl"
["soap"]="soap"
)

declare -a feature_subscription_map=(
# Auth features
"oauth_azure_ad" "ad" "ldap" "oidc" "saml"
# Database features
"ibmdb2" "sqlsrv" "sqlanywhere" "oracle"
# Notification features
"apn" "gcm"
# Other features
"soap" "limits" "logger"
)

# change tracking
declare -A chosen_features
declare -A chosen_settings
# menu control
declare -a menu_items

os_type() {
    case "$OSTYPE" in
      bsd*)     echo "BSD" ;;
      freebsd*) echo "BSD" ;;
      cygwin*)  echo "WINDOWS" ;;
      darwin*)  echo "OSX" ;;
      linux*)   echo "LINUX" ;;
      msys*)    echo "WINDOWS" ;;
      solaris*) echo "SOLARIS" ;;
      *)        echo "unknown: $OSTYPE" ;;
    esac
}

jq_available() {
    if jq --version >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

display_section() {
    textsize=${#1}
    width="$(tput cols)"
    span=$((($width + $textsize) / 2))
    bar=$(printf '%.0s=' $(seq 1 $width))
    printf "${bar}\n||%${span}s\n${bar}\n" "$1"
}

display_title() {
    textsize=${#1}
    width="$(tput cols)"
    span=$((($width + $textsize) / 2))
    bar=$(printf '%.0s-' $(seq 1 $width))
    printf "${bar}\n|%${span}s\n${bar}\n" "$1"
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

in_array() {
    local haystack=${1}[@]
    local needle=${2}
    for i in ${!haystack}; do
        if [[ "${i}" == "${needle}" ]]; then
            return 0
        fi
    done
    return 1
}

action_menu() {
    clear
    local title=${1} && shift
    local msg=${1} && shift
    local items=("$@")
    display_section "${title}"
    printf "\n$msg\n"
    for i in ${!items[@]}; do
        printf "%2d) %s\n" $((i+1)) "${items[i]}"
    done
    [[ "$action_error" ]] && echo "$action_error"; :
}

action_menu_handle() {
    action_error=""
    local title=${1} && shift
    local msg=${1} && shift
    local items=("$@")
    local prompt="What would you like to do? "
    while action_menu "${title}" "${msg}" "${items[@]}" && read -e -p "$prompt" action; do
        if (( action > 0 && action <= ${#items[@]} )); then
            break
        fi
        { action_error="Invalid selection: $action"; continue; }
    done
}

features_menu() {
    clear
    local title=${1}
    display_section "Feature Selections - ${title}"
    printf "\n$menu_msg\n"
    for i in ${!menu_items[@]}; do
        printf "%s %2d) %s" "${chosen_features[${menu_items[i]}]:- }" $((i+1)) "${features[${menu_items[i]}]}"
        in_array feature_subscription_map "${menu_items[i]}" && printf " (* subscription required)\n" || printf "\n";
    done
    [[ "$features_error" ]] && echo "$features_error"; :
}

features_menu_handle() {
    features_error=""
    local title=${1}
    local prompt="Select a number and ENTER to add (+) or remove () a feature, press ENTER when done: "
    while features_menu "${title}" && read -e -p "$prompt" num && [[ "$num" ]]; do
        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
            ((num--));
            [[ "${chosen_features[${menu_items[num]}]}" ]] && chosen_features[${menu_items[num]}]="" || chosen_features[${menu_items[num]}]="+"
        else
            features_error="Invalid selection: $num"; continue;
        fi
    done
}

settings_menu() {
    clear
    local title=${1}
    display_section "Environment Settings - ${title}"
    printf "\n$menu_msg\n"
    for i in ${!menu_items[@]}; do
        printf "%2d) %s=%s\n" $((i+1)) "${menu_items[i]}" "${settings[${menu_items[i]}]}"
    done
    [[ "$settings_error" ]] && printf "$settings_error"; :
}

settings_menu_handle() {
    settings_error=""
    local title=${1}
    local prompt="Select a number and ENTER to edit a setting, or just ENTER to accept all settings as displayed: "
    while settings_menu "${title}" && read -e -p "$prompt" num && [[ "$num" ]]; do
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
            settings_error="Invalid selection: $num"; continue;
        fi
    done
}

#-------------------------------------------
# Interactive portion
#-------------------------------------------
# Initialize variables
install_type="install"
env_source=".env-dist"

# pull default settings
mapfile -t env_lines < <(sed -e '/\s*#.*$/d' -e '/^\s*$/d' ${env_source})
for env_line in "${env_lines[@]}"; do
    env_key="${env_line%%=*}"
    env_val="${env_line#*=}"
    if [[ -n "${env_val}" && -n "${settings[${env_key}]+1}" ]]; then
        settings[${env_key}]="${env_val}"
    fi
done

if [ -f ".env" ] ; then
    action_title="Install or Upgrade"
    action_msg="A previous installation has been detected."
    action_items=(
    "Keep existing configuration"
    "Re-install from the defaults"
    "Cancel installation"
    )
    action_menu_handle "${action_title}" "${action_msg}" "${action_items[@]}"
    case $action in
        1 ) env_source=".env"
            # pull existing settings
            mapfile -t env_lines < <(sed -e '/\s*#.*$/d' -e '/^\s*$/d' ${env_source})
            for env_line in "${env_lines[@]}"; do
                env_key="${env_line%%=*}"
                env_val="${env_line#*=}"
                if [[ -n "${env_val}" && -n "${settings[${env_key}]+1}" ]]; then
                    settings[${env_key}]="${env_val}"
                fi
            done

            if [ -f "composer.json" ] ; then
                # pull existing features
                mapfile -t composer_requires < <(awk '/"require":/{flag=1; next} /\}/{flag=0} flag' composer.json)
                for composer_line in "${composer_requires[@]}"; do
                    pkg=$(qtrim $(trim "${composer_line%%:*}"))
                    if [ "dreamfactory" == "${pkg%%/*}" ]; then
                        pkg="${pkg#*/}"
                        for feature in "${!feature_package_map[@]}"; do
                            [[ "${pkg}" == "${feature_package_map[${feature}]}" ]] && chosen_features["${feature}"]="+"
                        done
                    fi
                done
            fi

            install_type="upgrade"
            ;;
        2 ) ;;
        3 ) exit ;;
    esac
fi

action_title="Feature Selections"
if [[ ${#chosen_features[@]} -ne 0 ]]; then
    action_msg="The following features have been detected from your installation:\n"
    action_msg+=$(for i in ${!chosen_features[@]}; do
        [[ "${chosen_features[${i}]}" ]] && printf "\t${features[${i}]}\n"
    done | sort)
    action_msg+="\nWould you like to change your feature list?"
    action_items=("Yes, change my features" "No, take features as is" "Cancel installation")
    action_menu_handle "${action_title}" "${action_msg}" "${action_items[@]}"
else
    action_msg="Select one of the following templates to start:"
    action_items=("Bare minimum" "Typical open-source features" "Everything available" "Cancel installation")
    action_menu_handle "${action_title}" "${action_msg}" "${action_items[@]}"
    case $action in
        1 ) starters=() ;;
        2 ) starters=("user" "mysql" "pgsql" "sqlite" "local_file" "smtp_email" "php" "v8js" "api_doc" "rws" "admin" "file_mgr" "api_doc_ui") ;;
        3 ) starters=("${!features[@]}") ;;
        4 ) exit ;;
    esac
    for feature in "${starters[@]}"; do
        chosen_features["${feature}"]="+"
    done
    action=1
fi
case $action in
    1 )
        action_msg="The following menus allow you select a list of desired features by section."
        action_msg+=" At the end of this script, the selections will be used to check for all required software and OS features."
        action_msg+=" To change any of these features at a later time, re-run this installation."
        action_msg+="\nChoose from the following feature sections:"
        action_error=""
        while action_menu "${action_title}" "${action_msg}" "${feature_groups[@]}" && read -e -p "Select a group by number, or press enter to be done. " group && [[ "$group" ]]; do
            if [[ "$group" != *[![:digit:]]* ]] && (( group > 0 && group <= ${#action_items[@]} )) ; then
                ((group--));
                menu_msg=${feature_group_prompts["${feature_groups[$group]}"]}
                menu_items=( ${features_in_groups["${feature_groups[$group]}"]} )
                features_menu_handle "${feature_groups[$group]}"
            else
                action_error="Invalid selection: $group"; continue;
            fi
        done
        ;;
    2 ) ;;
    3 ) exit;;
esac

clear
action_title="Environment Settings"
if [ -f ".env" ] ; then
    action_msg="The following settings have been detected from your environment:\n"
    declare -a print_settings=()
    action_msg+=$(for i in ${!settings[@]}; do
        [[ "${settings[${i}]}" ]] && printf "\t${i} = ${settings[${i}]}\n"
    done | sort)
    action_msg+="\nWould you like to change your environment settings?"
    action_items=("Yes, change my settings" "No, take settings as is" "Cancel installation")
    action_menu_handle "${action_title}" "${action_msg}" "${action_items[@]}"
else
    action=1
fi
case $action in
    1 )
        group_msg="The following menus allow you edit all of the allowed environment settings by section."
        group_msg+=" At the end of this script, the selections will be used to build/update the .env file."
        group_msg+=" To change any of these settings at a later time, either re-run this installation or edit the .env file manually."
        group_msg+="\nChoose from the following feature sections:"
        action_error=""
        while action_menu "${action_title}" "${group_msg}" "${settings_groups[@]}" && read -e -p "Select a group by number, or press enter to be done. " group && [[ "$group" ]]; do
            case $group in
                1 ) menu_msg="Current application settings:"
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

                    settings_menu_handle "Application Settings"
                    ;;

                2 ) case "${settings["DB_CONNECTION"]}" in
                        "sqlite" ) menu_items=("DB_CONNECTION" "DB_DATABASE")
                            [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="storage/databases/database.sqlite"
                            ;;
                        "mysql" ) menu_items=("DB_CONNECTION" "DB_HOST" "DB_PORT" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD" "DB_CHARSET" "DB_COLLATION")
                            [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                            [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                            [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="3306"
                            ;;
                        "pgsql" ) menu_items=("DB_CONNECTION" "DB_HOST" "DB_PORT" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD" "DB_CHARSET" "DB_COLLATION")
                            [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                            [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                            [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="5432"
                            ;;
                        "sqlsrv" ) menu_items=("DB_CONNECTION" "DB_HOST" "DB_PORT" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD" "DB_CHARSET" "DB_COLLATION")
                            [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                            [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                            [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="1433"
                            ;;
                    esac
                    menu_items=("DB_CONNECTION" "DB_HOST" "DB_PORT" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD" "DB_CHARSET" "DB_COLLATION")
                    menu_msg="Current system database settings:"
                    settings_error=""
                    prompt="Select a number and ENTER to edit a setting, or just ENTER to accept all settings as displayed: "
                    while settings_menu "System Database settings" && read -e -p "$prompt" num && [[ "$num" ]]; do
                        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
                            ((num--));
                            name="${menu_items[num]}"
                            [[ "${settings_msg[${name}]}" ]] && echo "${settings_msg[${name}]}"
                            read -e -p "Change the value of ${name} to [${settings_options[${name}]}]: " -i "${settings[${name}]}" choice
                            if [[ "${choice}" != "${settings[${name}]}" ]]; then
                                settings["${name}"]="${choice}"
                                chosen_settings["${name}"]="${choice}"
                            fi
                            if [[ 0 -eq $num ]] ; then
                                case "${choice}" in
                                    "sqlite" ) chosen_features["sqlite"]="+"
                                        menu_items=("DB_CONNECTION" "DB_DATABASE")
                                        [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="storage/databases/database.sqlite"
                                        ;;
                                    "mysql" ) chosen_features["mysql"]="+"
                                        menu_items=("DB_CONNECTION" "DB_HOST" "DB_PORT" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD" "DB_CHARSET" "DB_COLLATION")
                                        [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                                        [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                                        [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="3306"
                                        ;;
                                    "pgsql" ) chosen_features["pgsql"]="+"
                                        menu_items=("DB_CONNECTION" "DB_HOST" "DB_PORT" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD" "DB_CHARSET" "DB_COLLATION")
                                        [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                                        [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                                        [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="5432"
                                        ;;
                                    "sqlsrv" ) chosen_features["sqlsrv"]="+"
                                        menu_items=("DB_CONNECTION" "DB_HOST" "DB_PORT" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD" "DB_CHARSET" "DB_COLLATION")
                                        [[ -z "${settings[DB_DATABASE]}" ]] && settings["DB_DATABASE"]="dreamfactory"
                                        [[ -z "${settings[DB_HOST]}" ]] && settings["DB_HOST"]="127.0.0.1"
                                        [[ -z "${settings[DB_PORT]}" ]] && settings["DB_PORT"]="1433"
                                        ;;
                                esac
                            fi
                        else
                            settings_error="Invalid selection: $num"; continue;
                        fi
                    done

                    menu_msg="The following settings apply to all database services, not just the system database:"
                    menu_items=(
                    "DB_MAX_RECORDS_RETURNED"
                    "DF_SQLITE_STORAGE"
                    "DF_FREETDS_DUMP"
                    "DF_FREETDS_DUMPCONFIG"
                    )
                    settings_menu_handle "Database Settings"
                    ;;

                3 ) case "${settings["CACHE_DRIVER"]}" in
                        "file" ) menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL" "CACHE_PATH")
                            [[ -z "${settings[CACHE_PATH]}" ]] && settings["CACHE_PATH"]="storage/framework/cache/data"
                            ;;
                        "database" ) menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL" "CACHE_TABLE")
                            [[ -z "${settings[CACHE_TABLE]}" ]] && settings["CACHE_TABLE"]="cache"
                            ;;
                        "memcached" ) menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL" "MEMCACHED_HOST" "MEMCACHED_PORT" "MEMCACHED_USERNAME" "MEMCACHED_PASSWORD" "MEMCACHED_PERSISTENT_ID" "MEMCACHED_WEIGHT") ;;
                        "redis" ) menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL" "REDIS_HOST" "REDIS_PORT" "REDIS_DATABASE" "REDIS_PASSWORD") ;;
                        "apc" ) menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL") ;;
                        "array" ) menu_items=("CACHE_DRIVER") ;;
                    esac
                    menu_msg="Current system cache settings:"
                    settings_error=""
                    prompt="Select a number and ENTER to edit a setting, or just ENTER to accept all settings as displayed: "
                    while settings_menu "System Cache Settings" && read -e -p "$prompt" num && [[ "$num" ]]; do
                        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
                            ((num--));
                            name="${menu_items[num]}"
                            [[ "${settings_msg[${name}]}" ]] && echo "${settings_msg[${name}]}"
                            read -e -p "Change the value of ${name} to [${settings_options[${name}]}]: " -i "${settings[${name}]}" choice
                            if [[ "${choice}" != "${settings[${name}]}" ]]; then
                                settings["${name}"]="${choice}"
                                chosen_settings["${name}"]="${choice}"
                            fi
                            if [[ 0 -eq $num ]] ; then
                                case "${choice}" in
                                    "file" )
                                        menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL" "CACHE_PATH")
                                        [[ -z "${settings[CACHE_PATH]}" ]] && settings["CACHE_PATH"]="storage/framework/cache/data"
                                        ;;
                                    "database" )
                                        menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL" "CACHE_TABLE")
                                        [[ -z "${settings[CACHE_TABLE]}" ]] && settings["CACHE_TABLE"]="cache"
                                        ;;
                                    "memcached" ) chosen_features["memcached"]="+"
                                        menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL" "MEMCACHED_HOST" "MEMCACHED_PORT" "MEMCACHED_USERNAME" "MEMCACHED_PASSWORD" "MEMCACHED_PERSISTENT_ID" "MEMCACHED_WEIGHT")
                                        ;;
                                    "redis" ) chosen_features["redis"]="+"
                                        menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL" "REDIS_HOST" "REDIS_PORT" "REDIS_DATABASE" "REDIS_PASSWORD")
                                        ;;
                                    "apc" ) chosen_features["apc"]="+"
                                        menu_items=("CACHE_DRIVER" "CACHE_DEFAULT_TTL")
                                        ;;
                                    "array" )
                                        menu_items=("CACHE_DRIVER")
                                        ;;
                                esac
                            fi
                        else
                            settings_error="Invalid selection: $num"; continue;
                        fi
                    done

                    if [[ "${chosen_features[limits]}" ]]; then
                        menu_msg="Current limits cache settings:"
                        case "${settings["LIMIT_CACHE_DRIVER"]}" in
                            "file" ) menu_items=("LIMIT_CACHE_DRIVER" "LIMIT_CACHE_PATH")
                                [[ -z "${settings[LIMIT_CACHE_PATH]}" ]] && settings["LIMIT_CACHE_PATH"]="storage/framework/limit_cache"
                                ;;
                            "database" ) menu_items=("LIMIT_CACHE_DRIVER" "LIMIT_CACHE_TABLE")
                                [[ -z "${settings[LIMIT_CACHE_TABLE]}" ]] && settings["LIMIT_CACHE_TABLE"]="limit_cache"
                                ;;
                            "memcached" ) menu_items=("LIMIT_CACHE_DRIVER" "MEMCACHED_HOST" "MEMCACHED_PORT" "MEMCACHED_USERNAME" "MEMCACHED_PASSWORD" "MEMCACHED_PERSISTENT_ID" "MEMCACHED_WEIGHT") ;;
                            "redis" ) menu_items=("LIMIT_CACHE_DRIVER" "REDIS_HOST" "REDIS_PORT" "REDIS_DATABASE" "REDIS_PASSWORD") ;;
                            "apc" ) menu_items=("LIMIT_CACHE_DRIVER") ;;
                            "array" ) menu_items=("LIMIT_CACHE_DRIVER") ;;
                        esac
                        settings_error=""
                        prompt="Select a number and ENTER to edit a setting, or just ENTER to accept all settings as displayed: "
                        while settings_menu "Limits Settings" && read -e -p "$prompt" num && [[ "$num" ]]; do
                            if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
                                ((num--));
                                name="${menu_items[num]}"
                                [[ "${settings_msg[${name}]}" ]] && echo "${settings_msg[${name}]}"
                                read -e -p "Change the value of ${name} to [${settings_options[${name}]}]: " -i "${settings[${name}]}" choice
                                if [[ "${choice}" != "${settings[${name}]}" ]]; then
                                    settings["${name}"]="${choice}"
                                    chosen_settings["${name}"]="${choice}"
                                fi
                                if [[ 0 -eq $num ]] ; then
                                    case "${choice}" in
                                        "file" )
                                            menu_items=("LIMIT_CACHE_DRIVER" "LIMIT_CACHE_PATH")
                                            [[ -z "${settings[LIMIT_CACHE_PATH]}" ]] && settings["LIMIT_CACHE_PATH"]="storage/framework/limit_cache"
                                            ;;
                                        "database" )
                                            menu_items=("LIMIT_CACHE_DRIVER" "LIMIT_CACHE_TABLE")
                                            [[ -z "${settings[LIMIT_CACHE_TABLE]}" ]] && settings["LIMIT_CACHE_TABLE"]="limit_cache"
                                            ;;
                                        "memcached" ) chosen_features["memcached"]="+"
                                            menu_items=("LIMIT_CACHE_DRIVER" "MEMCACHED_HOST" "MEMCACHED_PORT" "MEMCACHED_USERNAME" "MEMCACHED_PASSWORD" "MEMCACHED_PERSISTENT_ID" "MEMCACHED_WEIGHT")
                                            ;;
                                        "redis" ) chosen_features["redis"]="+"
                                            menu_items=("LIMIT_CACHE_DRIVER" "REDIS_HOST" "REDIS_PORT" "REDIS_DATABASE" "REDIS_PASSWORD")
                                            ;;
                                        "apc" ) chosen_features["apc"]="+"
                                            menu_items=("LIMIT_CACHE_DRIVER")
                                            ;;
                                        "array" )
                                            menu_items=("LIMIT_CACHE_DRIVER")
                                            ;;
                                    esac
                                fi
                            else
                                settings_error="Invalid selection: $num"; continue;
                            fi
                        done
                    fi
                    ;;

                4 ) echo "Note: Using the driver 'sync' will execute queued jobs immediately and doesn't really use queuing.
                          Also using driver'null' discards jobs immediately, not executing them at all, useful for testing only."
                    case "${settings["QUEUE_DRIVER"]}" in
                        "sync" ) menu_items=("QUEUE_DRIVER") ;;
                        "database" ) menu_items=("QUEUE_DRIVER" "QUEUE_TABLE")
                            [[ -z "${settings[QUEUE_TABLE]}" ]] && settings["QUEUE_TABLE"]="jobs"
                            ;;
                        "beanstalkd" ) menu_items=("QUEUE_DRIVER" "BEANSTALKD_HOST") ;;
                        "redis" ) menu_items=("QUEUE_DRIVER" "REDIS_HOST" "REDIS_PORT" "REDIS_DATABASE" "REDIS_PASSWORD") ;;
                        "aws_sqs" ) menu_items=("QUEUE_DRIVER" "SQS_KEY" "SQS_SECRET" "SQS_REGION" "SQS_PREFIX") ;;
                        "null" ) menu_items=("QUEUE_DRIVER") ;;
                    esac
                    menu_msg="Current system queuing settings:"
                    settings_error=""
                    prompt="Select a number and ENTER to edit a setting, or just ENTER to accept all settings as displayed: "
                    while settings_menu "System Queuing Settings" && read -e -p "$prompt" num && [[ "$num" ]]; do
                        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
                            ((num--));
                            name="${menu_items[num]}"
                            [[ "${settings_msg[${name}]}" ]] && echo "${settings_msg[${name}]}"
                            read -e -p "Change the value of ${name} to [${settings_options[${name}]}]: " -i "${settings[${name}]}" choice
                            if [[ "${choice}" != "${settings[${name}]}" ]]; then
                                settings["${name}"]="${choice}"
                                chosen_settings["${name}"]="${choice}"
                            fi
                            if [[ 0 -eq $num ]] ; then
                                case "${choice}" in
                                    "sync" )
                                        menu_items=("QUEUE_DRIVER")
                                        ;;
                                    "database" )
                                        menu_items=("QUEUE_DRIVER" "QUEUE_TABLE")
                                        [[ -z "${settings[QUEUE_TABLE]}" ]] && settings["QUEUE_TABLE"]="jobs"
                                        ;;
                                    "beanstalkd" ) chosen_features["beanstalkd"]="+"
                                        menu_items=("QUEUE_DRIVER" "BEANSTALKD_HOST")
                                        ;;
                                    "redis" ) chosen_features["redis"]="+"
                                        menu_items=("QUEUE_DRIVER" "REDIS_HOST" "REDIS_PORT" "REDIS_DATABASE" "REDIS_PASSWORD")
                                        ;;
                                    "aws_sqs" ) chosen_features["apc"]="+"
                                        menu_items=("QUEUE_DRIVER" "SQS_KEY" "SQS_SECRET" "SQS_REGION" "SQS_PREFIX")
                                        ;;
                                    "null" )
                                        menu_items=("QUEUE_DRIVER")
                                        ;;
                                esac
                            fi
                        else
                            settings_error="Invalid selection: $num"; continue;
                        fi
                    done
                    ;;

                5 ) case "${settings["MAIL_DRIVER"]}" in
                        "smtp" ) menu_items=("MAIL_DRIVER" "MAIL_HOST" "MAIL_PORT" "MAIL_USERNAME" "MAIL_PASSWORD" "MAIL_ENCRYPTION" "MAIL_FROM_ADDRESS" "MAIL_FROM_NAME") ;;
                        "sendmail" )  menu_items=("MAIL_DRIVER") ;;
                        "mailgun" ) menu_items=("MAIL_DRIVER" "MAILGUN_DOMAIN" "MAILGUN_SECRET") ;;
                        "mandrill" ) menu_items=("MAIL_DRIVER" "MANDRILL_SECRET") ;;
                        "ses" ) menu_items=("MAIL_DRIVER" "SES_KEY" "SES_SECRET" "SES_REGION") ;;
                        "sparkpost" )  menu_items=("MAIL_DRIVER" "SPARKPOST_SECRET") ;;
                        "log" ) menu_items=("MAIL_DRIVER") ;;
                        "array" ) menu_items=("MAIL_DRIVER") ;;
                    esac
                    menu_msg="Current system mail settings:"
                    settings_error=""
                    prompt="Select a number and ENTER to edit a setting, or just ENTER to accept all settings as displayed: "
                    while settings_menu "System Email Settings" && read -e -p "$prompt" num && [[ "$num" ]]; do
                        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
                            ((num--));
                            name="${menu_items[num]}"
                            [[ "${settings_msg[${name}]}" ]] && echo "${settings_msg[${name}]}"
                            read -e -p "Change the value of ${name} to [${settings_options[${name}]}]: " -i "${settings[${name}]}" choice
                            if [[ "${choice}" != "${settings[${name}]}" ]]; then
                                settings["${name}"]="${choice}"
                                chosen_settings["${name}"]="${choice}"
                            fi
                            if [[ 0 -eq $num ]] ; then
                                case "${choice}" in
                                    "smtp" )
                                        menu_items=("MAIL_DRIVER" "MAIL_HOST" "MAIL_PORT" "MAIL_USERNAME" "MAIL_PASSWORD" "MAIL_ENCRYPTION" "MAIL_FROM_ADDRESS" "MAIL_FROM_NAME")
                                        ;;
                                    "sendmail" )
                                        menu_items=("MAIL_DRIVER")
                                        ;;
                                    "mailgun" ) chosen_features["mailgun"]="+"
                                        menu_items=("MAIL_DRIVER" "MAILGUN_DOMAIN" "MAILGUN_SECRET")
                                        ;;
                                    "mandrill" ) chosen_features["mandrill"]="+"
                                        menu_items=("MAIL_DRIVER" "MANDRILL_SECRET")
                                        ;;
                                    "ses" ) chosen_features["aws_ses"]="+"
                                        menu_items=("MAIL_DRIVER" "SES_KEY" "SES_SECRET" "SES_REGION")
                                        ;;
                                    "sparkpost" ) chosen_features["sparkpost"]="+"
                                        menu_items=("MAIL_DRIVER" "SPARKPOST_SECRET")
                                        ;;
                                    "log" )
                                        menu_items=("MAIL_DRIVER")
                                        ;;
                                    "array" )
                                        menu_items=("MAIL_DRIVER")
                                        ;;
                                esac
                            fi
                        else
                            settings_error="Invalid selection: $num"; continue;
                        fi
                    done
                    ;;

                6 ) menu_msg="The following settings the API layout and the way the system handles requests and responses:"
                    menu_items=(
                    "DF_API_ROUTE_PREFIX"
                    "DF_STATUS_ROUTE_PREFIX"
                    "DF_STORAGE_ROUTE_PREFIX"
                    "DF_XML_ROOT"
                    "DF_ALWAYS_WRAP_RESOURCES"
                    "DF_RESOURCE_WRAPPER"
                    "DF_CONTENT_TYPE"
                    )
                    settings_menu_handle "DreamFactory API Settings"
                    ;;

                7 ) menu_msg="The following settings apply to event scripting and scripting services:"
                    menu_items=("DF_SCRIPTING_DISABLE")
                    [[ "${chosen_features[nodejs]}" ]] && menu_items=("${menu_items[@]}" "DF_NODEJS_PATH")
                    [[ "${chosen_features[python]}" ]] && menu_items=("${menu_items[@]}" "DF_PYTHON_PATH")
                    settings_menu_handle

                    display_title "Authentication and Authorization Settings"
                    menu_msg="The following settings apply to the authentication and authorization services:"
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
                    settings_menu_handle "Server-side Scripting Settings"
                    ;;

                8 ) case "${settings["BROADCAST_DRIVER"]}" in
                        "pusher" ) menu_items=("BROADCAST_DRIVER" "PUSHER_APP_ID" "PUSHER_APP_KEY" "PUSHER_APP_SECRET") ;;
                        "redis" ) menu_items=("BROADCAST_DRIVER" "REDIS_HOST" "REDIS_PORT" "REDIS_DATABASE" "REDIS_PASSWORD") ;;
                        "log" ) menu_items=("BROADCAST_DRIVER") ;;
                        "null" ) menu_items=("BROADCAST_DRIVER") ;;
                    esac
                    menu_msg="Current event broadcast settings:"
                    settings_error=""
                    prompt="Select a number and ENTER to edit a setting, or just ENTER to accept all settings as displayed: "
                    while settings_menu "Event Broadcasting Settings" && read -e -p "$prompt" num && [[ "$num" ]]; do
                        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
                            ((num--));
                            name="${menu_items[num]}"
                            [[ "${settings_msg[${name}]}" ]] && echo "${settings_msg[${name}]}"
                            read -e -p "Change the value of ${name} to [${settings_options[${name}]}]: " -i "${settings[${name}]}" choice
                            if [[ "${choice}" != "${settings[${name}]}" ]]; then
                                settings["${name}"]="${choice}"
                                chosen_settings["${name}"]="${choice}"
                            fi
                            if [[ 0 -eq $num ]] ; then
                                case "${choice}" in
                                    "pusher" ) chosen_features["pusher"]="+"
                                        menu_items=("BROADCAST_DRIVER" "PUSHER_APP_ID" "PUSHER_APP_KEY" "PUSHER_APP_SECRET")
                                        ;;
                                    "redis" ) chosen_features["redis"]="+"
                                        menu_items=("BROADCAST_DRIVER" "REDIS_HOST" "REDIS_PORT" "REDIS_DATABASE" "REDIS_PASSWORD")
                                        ;;
                                    "log" )
                                        menu_items=("BROADCAST_DRIVER")
                                        ;;
                                    "null" )
                                        menu_items=("BROADCAST_DRIVER")
                                        ;;
                                esac
                            fi
                        else
                            settings_error="Invalid selection: $num"; continue;
                        fi
                    done
                    ;;

                9 ) menu_msg="The following settings apply to all database services, not just the system database:"
                    menu_items=(
                    "DF_FILE_CHUNK_SIZE"
                    "DF_PACKAGE_PATH"
                    "DF_LOOKUP_MODIFIERS"
                    "DF_INSTALL"
                    )
                    settings_menu_handle "Other Settings"
                    ;;
            esac
        done
        ;;
    2 ) ;;
    3 ) exit;;
esac

clear
if [[ "${chosen_settings[@]}" ]] ; then
    printf "\nChanges to make to environment:\n"
    for key in "${!chosen_settings[@]}"; do
        printf "\t${key}=${chosen_settings[$key]}\n"
    done | sort
    while read -e -p "Would you like to apply these environment settings? [y/n] " -n1 action; do
    case $action in
        [yY]* )
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
                if grep -q "^${to_find}" ".env"; then
                    sed -i'.tmp' "s/^$to_find.*/$to_replace/g" ".env"
                elif grep -q "^#${to_find}" ".env"; then
                    sed -i'.tmp' "s/^#$to_find.*/$to_replace/g" ".env"
                else
                    # append at end of file
                    echo "{$to_replace}" >> ".env"
                fi
            done
            echo "Changes applied to .env file."
            break
          ;;
        [nN]* ) break ;;
        * ) echo "Invalid response, please answer y (yes) or n (no)" ;;
    esac
    done
else
    printf "\nNo changes to make to environment settings.\n"
fi


if [[ "${chosen_features[@]}" ]] ; then
    printf "\nFeatures selected for this install:\n"
    # build required packages and extensions
    declare -a req_pkgs
    declare -a req_exts=("openssl" "PDO" "mbstring" "tokenizer" "xml")
    for K in "${!chosen_features[@]}"; do [[ "${chosen_features[${K}]}" ]] && echo "${features[${K}]}"; done | sort
    for K in "${!chosen_features[@]}"; do
        if [[ "${chosen_features[${K}]}" ]]; then
            if [[ "${feature_package_map[${K}]}" ]] ; then
                pkg="${feature_package_map[${K}]}"
                [[ "${pkg}" == */* ]] || pkg="dreamfactory/${pkg}";
                in_array req_pkgs "${pkg}" || req_pkgs=("${req_pkgs[@]}" "${pkg}")
            fi
            if [[ "${feature_extension_map[${K}]}" ]] ; then
                ext="${feature_extension_map[${K}]}"
                in_array req_exts "${ext}" || req_exts=("${req_exts[@]}" "${ext}")
            fi
        fi
    done

    printf "\nRequired composer packages for this install:\n"
    for V in "${req_pkgs[@]}"; do printf "\t${V}\n"; done
    while read -e -p "Would you like to apply these feature changes to your composer setup? [y/n] " -n1 action; do
        case $action in
            [yY]* )
                if [ -f "composer.json" ] ; then
                    # backup existing composer.json
                    cp "composer.json" "composer.json-install-bkup"
                    # if clean install, overwrite the existing composer.json
                    [[ "install"="${install_type}" ]] && cp "composer.json-dist" "composer.json"
                else
                    cp "composer.json-dist" "composer.json"
                fi

#                if [[ jq_available ]] ; then
#                    echo $(jq .require composer.json-dist)
#                else
                    mapfile -t base_requires < <(awk '/"require":/{flag=1; next} /\}/{flag=0} flag' composer.json-dist)
                    require=""
                    for V in "${req_pkgs[@]}"; do require+="    \"${V}\": \"dev-develop as dev-master\",\n"; done
                    for V in "${base_requires[@]}"; do require+="${V}\n"; done
                    awk -v out="${require}" '/"require":/{p=1;print;print out}/\}/{p=0}!p' composer.json > composer.tmp && mv composer.tmp composer.json
#                fi
                echo "Changes applied to composer.json file."
                break
                ;;
            [nN]* ) break ;;
            * ) echo "Invalid response, please answer y (yes) or n (no)" ;;
        esac
    done

    if php --version >/dev/null 2>&1; then
        cur_exts=($(php -r '$exts=get_loaded_extensions(); foreach ($exts as $ext) { echo "$ext\n"; }'))
        declare -a installed_exts
        declare -a required_exts
        for V in "${req_exts[@]}"; do
            in_array cur_exts "${V}" && installed_exts=("${installed_exts[@]}" "${V}") || required_exts=("${required_exts[@]}" "${V}");
        done
        printf "\nRequired PHP extensions already installed:\n"
        for V in "${installed_exts[@]}"; do printf "\t${V}\n"; done
        printf "\nRequired PHP extensions that need to be installed:\n"
        for V in "${required_exts[@]}"; do printf "\t${V}\n"; done
    else
        printf "\nDreamFactory requires PHP to run, but can not be detected on this system.\n"
        printf "Please check that it is installed along with all of the following required PHP extensions:\n"
        for V in "${req_exts[@]}"; do printf "\t${V}\n"; done
    fi

else
    printf "\nNo changes to make to supported features.\n"
fi

