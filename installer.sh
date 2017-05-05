#!/usr/bin/env bash

# check whether whiptail or dialog is installed
# (choosing the first command found)
read dialog <<< "$(which whiptail dialog 2> /dev/null)"

# exit if none found
[[ "$dialog" ]] || {
  echo 'Installer can not run due to neither whiptail nor dialog being found.' >&2
  exit 1
}

# add preliminary helper text for what we are about to do
echo "Welcome to the DreamFactory Installer."
echo "During this installation process, follow the prompts requesting various selections about the features and environment settings desired."

## If you are using an older installation of DreamFactory 2 and getting following error
## 'No supported encrypter found. The cipher and / or key length are invalid' then please
## uncomment the following line to use rijndael-128 cipher. Using this cipher requires the
## php mcrypt extension to be installed.

declare -A settings=(
# Application settings
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
# Database settings
["DB_CONNECTION"]="sqlite"
["DB_HOST"]=""
["DB_PORT"]=""
["DB_DATABASE"]="database.sqlite"
["DB_USERNAME"]=""
["DB_PASSWORD"]=""
["DB_CHARSET"]=""
["DB_COLLATION"]=""
# Cache settings
["CACHE_DRIVER"]="file"
["CACHE_PATH"]="framework/cache/data"
["CACHE_TABLE"]="cache"
["CACHE_CONNECTION"]=""
["MEMCACHED_PERSISTENT_ID"]=""
["MEMCACHED_USERNAME"]=""
["MEMCACHED_PASSWORD"]=""
["MEMCACHED_HOST"]="127.0.0.1"
["MEMCACHED_PORT"]="11211"
["MEMCACHED_WEIGHT"]=""
# Queue settings
["QUEUE_DRIVER"]="database"
)

declare -A settings_msg=(
# Application setting options
["APP_CIPHER"]="If you are using an older installation of DreamFactory 2 and getting following error. 'No supported encrypter found. The cipher and / or key length are invalid' then please use rijndael-128 cipher. Using this cipher requires the php mcrypt extension to be installed."
["APP_DEBUG"]="When your application is in debug mode, detailed error messages with stack traces will be shown on every error that occurs within your application. If disabled, a simple generic error page is shown."
["APP_ENV"]="This may determine how various services behave in your application."
["APP_KEY"]="This key is used by the application for encryption and should be set to a random, 32 character string, otherwise these encrypted strings will not be safe. Use 'php artisan key:generate' to generate a new key. Please do this before deploying an application!"
["APP_LOCALE"]="The application locale determines the default locale that will be used by the translation service provider. Currently only 'en' (English) is supported."
["APP_LOG"]="This setting control the placement and rotation of the log file used by the application."
["APP_LOG_LEVEL"]="warning"
['APP_NAME']="This value is used when the framework needs to place the application's name in a notification or any other location as required by the application or its packages."
["APP_TIMEZONE"]="Here you may specify the default timezone for your application, which will be used by the PHP date and date-time functions."
["APP_URL"]="This URL is used by the console to properly generate URLs when using the Artisan command line tool. You should set this to the root of your application so that it is used when running Artisan tasks."
# Database settings
["DB_CONNECTION"]="sqlite"
["DB_HOST"]="127.0.0.1"
["DB_PORT"]="3306"
["DB_DATABASE"]="dreamfactory"
["DB_USERNAME"]=""
["DB_PASSWORD"]=""
["DB_CHARSET"]="Defaults use utf8mb4 for MySQL-based database, may cause problems for pre-5.7.7 (MySQL) or pre-10.2.2 (MariaDB), use utf8."
["DB_COLLATION"]="Defaults use utf8mb4_unicode_ci for MySQL-based database, may cause problems for pre-5.7.7 (MySQL) or pre-10.2.2 (MariaDB), use utf8_unicode_ci."
# Cache settings
["CACHE_DRIVER"]="file"
["CACHE_PATH"]="framework/cache/data"
["CACHE_TABLE"]="cache"
["CACHE_CONNECTION"]=""
["MEMCACHED_PERSISTENT_ID"]=""
["MEMCACHED_USERNAME"]=""
["MEMCACHED_PASSWORD"]=""
["MEMCACHED_HOST"]="127.0.0.1"
["MEMCACHED_PORT"]="11211"
["MEMCACHED_WEIGHT"]=""
# Queue settings
["QUEUE_DRIVER"]="database"
)

declare -A settings_options=(
# Application setting options
["APP_DEBUG"]="true, false"
["APP_ENV"]="local, production"
["APP_LOCALE"]="en"
["APP_LOG"]="single, daily, syslog, errorlog"
["APP_LOG_LEVEL"]="debug, info, notice, warning, error, critical, alert, emergency"
# Database setting options
["DB_CONNECTION"]="sqlite, mysql, pgsql, sqlsrv"
# Cache setting options
["CACHE_DRIVER"]="apc, array, database, file, memcached, redis"
# Queue setting options
["QUEUE_DRIVER"]="sync, database, beanstalkd, sqs, redis, null"
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

# change tracking
declare -a chosen_features
declare -A chosen_settings
# menu control
declare -a menu_items
declare -a chosen_items

display_title() {
    echo ""
    echo "----------------------------------------"
    echo "|  $1"
    echo "----------------------------------------"
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
    while action_menu && read -e -p "$prompt" -n1 choice; do
        if (( choice > 0 && choice <= ${#menu_items[@]} )); then
            break
        fi
        { msg="Invalid option: $choice"; continue; }
    done
}

features_menu() {
    echo "$menu_msg"
    for i in ${!menu_items[@]}; do
        printf "%s %2d) %s\n" "${chosen_items[i]:- }" $((i+1)) "${features[${menu_items[i]}]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

features_menu_handle() {
    msg=""
    prompt="Select a number and ENTER to add (+) or remove () a feature, press ENTER when done: "
    while features_menu && read -e -p "$prompt" num && [[ "$num" ]]; do
        if [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#menu_items[@]} )) ; then
            ((num--));
            [[ "${chosen_items[num]}" ]] && chosen_items[num]="" || chosen_items[num]="+"
        else
            msg="Invalid option: $num"; continue;
        fi
    done

    for i in ${!chosen_items[@]}; do
        if [[ "${chosen_items[i]}" ]]; then
            chosen_features+="${menu_items[i]}"
        fi
    done
    # clear the choices
    chosen_items=()
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
            read -e -p "Change the value of ${name} to [${settings_options[${name}]}]: " -i "${settings[${name}]}" choice
            if [[ "${choice}"!=${settings["${name}"]} ]]; then
                settings["${name}"]="${choice}"
                chosen_settings["${name}"]="${choice}"
            fi
        else
            msg="Invalid option: $num"; continue;
        fi
    done
}

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
    case $choice in
      1 ) [ -f ".env" ] && env_source=".env"
          [ -f "composer.json" ] && composer_source="composer.json"
          install_type="upgrade"
          ;;
      2 ) ;;
      3 ) exit;;
    esac
fi

mapfile -t env_lines < ${env_source}
#printf "%s\n" "${env_lines[@]}"
#echo ${env_lines[4]}


display_title "Environment Settings"
menu_msg="The following menus allow you edit all of the allowed environment settings by section.
At the end of this script, the selections will be used to build/update the .env file.
To change any of these settings at a later time, either re-run this installation or edit the .env file manually."
menu_items=("Continue" "Skip this section (use defaults or existing settings)" "Cancel installation")
action_menu_handle
case $choice in
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
        )

        settings_menu_handle

        display_title "System Database settings"
        menu_msg="Current system database settings:"
        menu_items=(
        "DB_CONNECTION"
        "DB_HOST"
        "DB_PORT"
        "DB_DATABASE"
        "DB_USERNAME"
        "DB_PASSWORD"
        "DB_CHARSET"
        "DB_COLLATION"
        )

        settings_menu_handle

        #read -e -p "Would you like to edit or see other options for any of these settings? [y/n]" choice
        #if [[ "$choice" == [Yy]* ]]; then
        #    APP_NAME=$("$dialog" --title "System Database Config" --radiolist \
        #    "Which database connection type would you like to use for DreamFactory system tables?" 15 60 4 \
        #    "sqlite" "SQLite"
        #    "mysql" "MySQL, MariaDB, Percona, etc."
        #    "pgsql" "Postgre SQL"
        #    "sqlsrv" "MS SQL Server" OFF 3>&1 1>&2 2>&3)
        #
        #    exitstatus=$?
        #    if [ $exitstatus = 0 ]; then
        #        echo "The chosen database connection type is:" $DB_CONNECTION
        #    else
        #        echo "You chose Cancel."
        #    fi
        #fi

        display_title "System Cache Settings"
        menu_msg="Current system cache settings:"
        menu_items=(
        "CACHE_DRIVER"
        "CACHE_PATH"
        "CACHE_TABLE"
        "CACHE_CONNECTION"
        "MEMCACHED_PERSISTENT_ID"
        "MEMCACHED_USERNAME"
        "MEMCACHED_PASSWORD"
        "MEMCACHED_HOST"
        "MEMCACHED_PORT"
        "MEMCACHED_WEIGHT"
        )

        settings_menu_handle

        display_title "System Queuing Settings"
        menu_msg="Current system queuing settings:"
        menu_items=(
        "QUEUE_DRIVER"
        )

        settings_menu_handle

        # File settings
        # JWT/Session settings
        # DreamFactory-specific settings
        ;;
    2 ) ;;
    3 ) exit;;
esac

display_title "Feature Selections"
menu_msg="The following menus allow you select a list of desired features by section.
At the end of this script, the selections will be used to install and check for all required software and OS features.
To change any of these settings at a later time, re-run this installation."
menu_items=("Continue" "Skip this section (use the defaults or existing settings)" "Cancel installation")
action_menu_handle
case $choice in
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
for K in "${!chosen_settings[@]}"; do echo "${K}" "${chosen_settings[$K]}"; done

echo "Features selected for this install:"
for K in "${!chosen_features[@]}"; do echo "${chosen_features[$K]}"; done

exit

{
    for ((i = 0 ; i <= 100 ; i+=20)); do
        sleep 1
        echo $i
    done
} | "$dialog" --gauge "Please wait while installing" 6 60 0

