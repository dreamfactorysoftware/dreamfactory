#!/bin/bash
# Colors schemes for echo:
RD='\033[0;31m' # Red
BL='\033[1;34m' # Blue
GN='\033[0;32m' # Green
MG='\033[0;95m' # Magenta
NC='\033[0m'    # No Color

TERM_COLS="$(tput cols)"
ERROR_STRING="Installation error. Exiting"
CURRENT_PATH=$(pwd)

DEFAULT_PHP_VERSION="php8.3"

CURRENT_KERNEL=$(grep -w ID /etc/os-release | cut -d "=" -f 2 | tr -d '"')
CURRENT_OS=$(grep -e VERSION_ID /etc/os-release | cut -d "=" -f 2 | cut -d "." -f 1 | tr -d '"')

ERROR_STRING="Installation error. Exiting"

echo_with_color() {
  case $1 in
  Red | RED | red)
    echo -e "${NC}${RD} $2 ${NC}"
    ;;
  Green | GREEN | green)
    echo -e "${NC}${GN} $2 ${NC}"
    ;;
  Magenta | MAGENTA | magenta)
    echo -e "${NC}${MG} $2 ${NC}"
    ;;
  Blue | BLUE | blue)
    echo -e "${NC}${BL} $2 ${NC}"
    ;;
  *)
    echo -e "${NC} $2 ${NC}"
    ;;
  esac
}

## Puts text in the center of the terminal, just for layout / making things pretty
print_centered() {
  [[ $# == 0 ]] && return 1

  declare -i TERM_COLS="$(tput cols)"
  declare -i str_len="${#1}"
  [[ $str_len -ge $TERM_COLS ]] && {
      echo "$1";
      return 0;
  }

  declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
  [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
  filler=""
  for (( i = 0; i < filler_len; i++ )); do
      filler="${filler}${ch}"
  done

  printf "%s%s%s" "$filler" "$1" "$filler"
  [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
  printf "\n"

  return 0
}

## Used for each of the individual components to be installed
run_process () {
  while true; do echo -n . >&5; sleep 1; done &
  trap 'kill $BGPID; exit' INT
  BGPID=$!
  echo -n "$1" >&5
  $2
  echo done >&5
  kill $!
}

clear

# Make sure script run as sudo
if ((EUID != 0)); then
  echo -e "${RD}\nPlease run script with root privileges: sudo ./dfsetup.run \n"
  exit 1
fi

#### Check Current OS is compatible with the installer ####
case $CURRENT_KERNEL in
  ubuntu)
    if ((CURRENT_OS != 22)) && ((CURRENT_OS != 24)); then
      echo_with_color red "The installer only supports Ubuntu 22 and 24. Exiting...\n"
      exit 1
    fi
    ;;
  debian)
    if ((CURRENT_OS != 10)) && ((CURRENT_OS != 11)); then
      echo_with_color red "The installer only supports Debian 10 and 11. Exiting...\n"
      exit 1
    fi
    ;;
  centos | rhel)
    if ((CURRENT_OS != 7)) && ((CURRENT_OS != 8)); then
      echo_with_color red "The installer only supports Rhel (Centos) 7 and 8. Exiting...\n"
      exit 1
    fi
    ;;
  fedora)
    if ((CURRENT_OS != 36)) && ((CURRENT_OS != 37)); then
      echo_with_color red "The installer only supports Fedora 36, 37. Exiting...\n"
      exit 1
    fi
    ;;
  *)
    echo_with_color red "Installer only supported on Ubuntu, Debian, Rhel (Centos) and Fedora. Exiting...\n"
    exit 1
    ;;

esac

print_centered "-" "-"
print_centered "-" "-"
print_centered "Welcome to DreamFactory!"
print_centered "-" "-"
print_centered "-" "-"
print_centered "Thank you for choosing DreamFactory. By default this installer will install the latest version of DreamFactory with a preconfigured Nginx web server. Additional options are available in the menu below:"
print_centered "-" "-"
echo -e ""
echo -e "[0] Default Installation (latest version of DreamFactory with Nginx Server)"
echo -e "[1] Install driver and PHP extensions for Oracle DB"
echo -e "[2] Install driver and PHP extensions for IBM DB2"
echo -e "[3] Install driver and PHP extensions for Cassandra DB"
echo -e "[4] Install Apache2 web server for DreamFactory (Instead of Nginx)"
echo -e "[5] Install MariaDB as the default system database for DreamFactory"
echo -e "[6] Install a specfic version of DreamFactory"
echo -e "[7] Run Installation in debug mode (logs will output to /tmp/dreamfactory_installer.log)"
echo -e "[8] Upgrade DreamFactory\n"

print_centered "-" "-"
echo_with_color magenta "Input '0' and press Enter to run the default installation. To install additional options, type the corresponding number (e.g. '1,5' for Oracle and a MySql system database) from the menu above and press Enter"
read -r INSTALLATION_OPTIONS
print_centered "-" "-"


if [[ $INSTALLATION_OPTIONS == *"1"* ]]; then
  ORACLE=TRUE
  echo_with_color green "Oracle selected."
fi

if [[ $INSTALLATION_OPTIONS == *"2"* ]]; then
  DB2=TRUE
  echo_with_color green "DB2 selected."
fi

if [[ $INSTALLATION_OPTIONS == *"3"* ]]; then
  CASSANDRA=TRUE
  echo_with_color green "Cassandra selected."
fi

if [[ $INSTALLATION_OPTIONS == *"4"* ]]; then
  APACHE=TRUE
  echo_with_color green "Apache selected."
fi

if [[ $INSTALLATION_OPTIONS == *"5"* ]]; then
  MYSQL=TRUE
  echo_with_color green "MariaDB System Database selected."
fi

if [[ $INSTALLATION_OPTIONS == *"6"* ]]; then
  echo_with_color magenta "What version of DreamFactory would you like to install? (E.g. 4.9.0)"
  read -r -p "DreamFactory Version: " DREAMFACTORY_VERSION_TAG
  echo_with_color green "DreamFactory Version ${DREAMFACTORY_VERSION_TAG} selected."
fi

if [[ $INSTALLATION_OPTIONS == *"7"* ]]; then
  DEBUG=TRUE
  echo_with_color green "Running in debug mode. Run this command: tail -f /tmp/dreamfactory_installer.log in a new terminal session to follow logs during installation"
fi

if [[ ! $DEBUG == TRUE ]]; then
  exec 5>&1            # Save a copy of STDOUT
  exec >/dev/null 2>&1 # Redirect STDOUT to Null
else
  exec 5>&1 # Save a copy of STDOUT. Used because all echo redirects output to 5.
  exec >/tmp/dreamfactory_installer.log 2>&1
fi

# Retrieve executing user's username
CURRENT_USER=$(logname)

if [[ -z $SUDO_USER ]] && [[ -z $CURRENT_USER ]]; then
  echo_with_color red "Enter username for installation DreamFactory:" >&5
  read -r CURRENT_USER
  if [[ $CURRENT_KERNEL == "debian" ]]; then
    su "${CURRENT_USER}" -c "echo 'Checking user availability'" >&5
    if (($? >= 1)); then
      echo 'Please provide another user' >&5
      exit 1
    fi
  fi
fi

if [[ -n $SUDO_USER ]]; then
  CURRENT_USER=${SUDO_USER}
fi

# Sudo should be used to run the script, but CURRENT_USER themselves should not be root (i.e should be another user running with sudo),
# otherwise composer will get annoyed. If the user wishes to continue as root, then an environment variable will be set when 'composer install' is run later on in the script.
if [[ $CURRENT_USER == "root" ]]; then
  echo -e "WARNING: Although this script must be run with sudo, it is not recommended to install DreamFactory as root (specifically 'composer' commands) Would you like to:\n [1] Continue as root\n [2] Provide username for installing DreamFactory" >&5
  read -r INSTALL_AS_ROOT
  if [[ $INSTALL_AS_ROOT == 1 ]]; then
    echo -e "Continuing installation as root" >&5
  else
    echo -e "Enter username for installing DreamFactory" >&5
    read -r CURRENT_USER
    echo -e "User: ${CURRENT_USER} selected. Continuing" >&5
  fi
fi

echo -e "${CURRENT_KERNEL^} ${CURRENT_OS} detected. Installing DreamFactory...\n" >&5
#Go into the individual scripts here
case $CURRENT_KERNEL in
  ubuntu)
    source ./ubuntu.sh
    ;;
  debian)
    source ./debian.sh
    ;;
  centos | rhel)
    source ./centos.sh
    ;;
  fedora)
    source ./fedora.sh
    ;;
esac

#### INSTALLER ####

if [[ $INSTALLATION_OPTIONS == *"8"* ]]; then
  echo_with_color green "Upgrading DreamFactory selected.\n" >&5
  run_process "   Upgrading DreamFactory" upgrade_dreamfactory
  echo_with_color green "\nFinished Upgrading DreamFactory." >&5

  exit 0
fi

### STEP 1. Install system dependencies
echo_with_color blue "Step 1: Installing system dependencies...\n" >&5
run_process "   Updating System" system_update
run_process "   Installing System Dependencies" install_system_dependencies
echo_with_color green "\nThe system dependencies have been successfully installed.\n" >&5

### Step 2. Install PHP
echo_with_color blue "Step 2: Installing PHP...\n" >&5
run_process "   Installing PHP" install_php
echo_with_color green "\nPHP installed.\n" >&5

### Step 3. Install Apache
if [[ $APACHE == TRUE ]]; then ### Only with key --apache
  echo_with_color blue "Step 3: Installing Apache...\n" >&5
  # Check Apache installation status
  check_apache_installation_status
  if ((CHECK_APACHE_PROCESS == 0)) || ((CHECK_APACHE_INSTALLATION == 0)); then
    echo_with_color red "Apache2 detected. Skipping installation. Configure Apache2 manually.\n" >&5
  else
    # Install Apache
    # Check if running web server on port 80
    lsof -i :80 | grep LISTEN
    if (($? == 0)); then
      echo_with_color red "Port 80 taken.\n " >&5
      echo_with_color red "Skipping installation Apache2. Install Apache2 manually.\n " >&5
    else
      run_process "   Installing Apache" install_apache
      run_process "   Restarting Apache" restart_apache
      echo_with_color green "\nApache2 installed.\n" >&5
    fi
  fi

else
  echo_with_color blue "Step 3: Installing Nginx...\n" >&5 ### Default choice
  # Check nginx installation in the system
  check_nginx_installation_status
  if ((CHECK_NGINX_PROCESS == 0)) || ((CHECK_NGINX_INSTALLATION == 0)); then
    echo_with_color red "Nginx detected. Skipping installation. Configure Nginx manually.\n" >&5
  else
    # Install nginx
    # Checking running web server
    lsof -i :80 | grep LISTEN
    if (($? == 0)); then
      echo_with_color red "Port 80 taken.\n " >&5
      echo_with_color red "Skipping Nginx installation. Install Nginx manually.\n " >&5
    else
      run_process "   Installing Nginx" install_nginx
      run_process "   Restarting Nginx" restart_nginx
      echo_with_color green "\nNginx installed.\n" >&5
    fi
  fi
fi

### Step 4. Configure PHP development tools
echo_with_color blue "Step 4: Configuring PHP Extensions...\n" >&5

## Install PHP PEAR
run_process "   Installing PHP PEAR" install_php_pear
echo_with_color green "    PHP PEAR installed\n" >&5

### Install ZIP
if [[ $CURRENT_KERNEL == "fedora" ]]; then
  php -m | grep -E "^zip"
  if (($? >= 1)); then
    run_process "   Installing zip" install_zip
    php -m | grep -E "^zip"
    if (($? >= 1)); then
      echo_with_color red "\nExtension Zip has errors..." >&5
    else
      echo_with_color green "   Zip installed\n" >&5
    fi
  fi
fi

### Install MCrypt
php -m | grep -E "^mcrypt"
if (($? >= 1)); then
  run_process "   Installing Mcrypt" install_mcrypt
  php -m | grep -E "^mcrypt"
  if (($? >= 1)); then
    echo_with_color red "\nMcrypt installation error." >&5
  else
    echo_with_color green "    Mcrypt installed\n" >&5
  fi
fi

### Install MongoDB drivers
php -m | grep -E "^mongodb"
if (($? >= 1)); then
  run_process "   Installing Mongodb" install_mongodb
  php -m | grep -E "^mongodb"
  if (($? >= 1)); then
    echo_with_color red "\nMongoDB installation error." >&5
  else
    echo_with_color green "    MongoDB installed\n" >&5
  fi
fi

### Install MS SQL Drivers
php -m | grep -E "^sqlsrv"
if (($? >= 1)); then
  run_process "   Installing MS SQL Server" install_sql_server
  run_process "   Installing pdo_sqlsrv" install_pdo_sqlsrv
  php -m | grep -E "^sqlsrv"
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
  else
    echo_with_color green "    MS SQL Server extension installed\n" >&5
  fi
  php -m | grep -E "^pdo_sqlsrv"
  if (($? >= 1)); then
    echo_with_color red "\nCould not install pdo_sqlsrv extension" >&5
  else
    echo_with_color green "    pdo_sqlsrv installed\n" >&5
  fi
fi


### DRIVERS FOR ORACLE ( ONLY WITH KEY --with-oracle )
php -m | grep -E "^oci8"
if (($? >= 1)); then
  if [[ $ORACLE == TRUE ]]; then
    echo_with_color magenta "Enter absolute path to the Oracle drivers, complete with trailing slash: [/] " >&5
    read -r DRIVERS_PATH
    if [[ -z $DRIVERS_PATH ]]; then
      DRIVERS_PATH="."
    fi
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      unzip "$DRIVERS_PATH/instantclient-*.zip" -d /opt/oracle
    else
      ls -f $DRIVERS_PATH/oracle-instantclient*-*-[12][19].*.0.0.0*.x86_64.rpm
    fi
    if (($? == 0)); then
      run_process "   Drivers Found. Installing Oracle Drivers" install_oracle
      php -m | grep -E "^oci8"
      if (($? >= 1)); then
        echo_with_color red "\nCould not install oci8 extension." >&5
      else
        echo_with_color green "    Oracle drivers and oci8 extension installed\n" >&5
      fi
    else
      echo_with_color red "Drivers not found. Skipping...\n" >&5
    fi
    unset DRIVERS_PATH
  fi
fi

### DRIVERS FOR IBM DB2 PDO ( ONLY WITH KEY --with-db2 )
php -m | grep -E "^pdo_ibm"
if (($? >= 1)); then
  if [[ $DB2 == TRUE ]]; then
    echo_with_color magenta "Enter absolute path to the IBM DB2 drivers, complete with trailing slash: [/] " >&5
    read -r DRIVERS_PATH
    if [[ -z $DRIVERS_PATH ]]; then
      DRIVERS_PATH="."
    fi
    tar xzf $DRIVERS_PATH/ibm_data_server_driver_package_linuxx64_v11.5.tar.gz -C /opt/
    if (($? == 0)); then
      run_process "   Drivers Found. Installing DB2" install_db2
      php -m | grep pdo_ibm
      if (($? >= 1)); then
        echo_with_color red "\nCould not install pdo_ibm extension." >&5
      else
        ### DRIVERS FOR IBM DB2 ( ONLY WITH KEY --with-db2 )
        php -m | grep -E "^ibm_db2"
        if (($? >= 1)); then
          run_process "   Installing ibm_db2 extension" install_db2_extension
          php -m | grep ibm_db2
          if (($? >= 1)); then
            echo_with_color red "\nCould not install ibm_db2 extension." >&5
          else
            echo_with_color green "    IBM DB2 installed\n" >&5
          fi
        fi
      fi
    else
      echo_with_color red "Drivers not found. Skipping...\n" >&5
    fi
    unset DRIVERS_PATH
    cd "${CURRENT_PATH}" || exit 1
    rm -rf /opt/PDO_IBM-1.3.4-patched
  fi
fi

### DRIVERS FOR CASSANDRA ( ONLY WITH KEY --with-cassandra )
php -m | grep -E "^cassandra"
if (($? >= 1)); then
  if [[ $CASSANDRA == TRUE ]]; then
    run_process "   Installing Cassandra" install_cassandra
    php -m | grep cassandra
    if (($? >= 1)); then
      echo_with_color red "\nCould not install cassandra extension." >&5
    else
      echo_with_color green "    Cassandra installed\n" >&5
    fi
  fi
fi

### INSTALL IGBINARY EXT.
php -m | grep -E "^igbinary"
if (($? >= 1)); then
  run_process "   Installing igbinary" install_igbinary
  php -m | grep igbinary
  if (($? >= 1)); then
    echo_with_color red "\nCould not install igbinary extension." >&5
  else
    echo_with_color green "    igbinary installed\n" >&5
  fi
fi

### INSTALL PYTHON BUNCH
run_process "   Installing python2" install_python2
check_bunch_installation
if (($? >= 1)); then
  run_process "   Installing bunch" install_bunch
  check_bunch_installation
  if (($? >= 1)); then
    echo_with_color red "\nCould not install python bunch extension." >&5
  else
    echo_with_color green "    python2 installed\n" >&5
  fi
fi

### INSTALL PYTHON3 MUNCH
run_process "   Installing python3" install_python3
check_munch_installation
if (($? >= 1)); then
  run_process "   Installing munch" install_munch
  check_munch_installation
  if (($? >= 1)); then
    echo_with_color red "\nCould not install python3 munch extension." >&5
  else
    echo_with_color green "    python3 installed\n" >&5
  fi
fi

### Install Node.js
node -v
if (($? >= 1)); then
  run_process "   Installing node" install_node
  echo_with_color green "    node installed\n" >&5
fi

### INSTALL Snowflake
if [[ $CURRENT_KERNEL == "debian" || $CURRENT_KERNEL == "ubuntu" ]]; then
  if [[ $APACHE == TRUE ]]; then ### Only with key --apache
    ls /etc/php/${PHP_VERSION_INDEX}/apache2/conf.d | grep "snowflake"
    if (($? >= 1)); then
      run_process "   Installing snowflake" install_snowflake_apache
      echo_with_color green "    Snowflake installed\n" >&5
    fi
  else
    ls /etc/php/${PHP_VERSION_INDEX}/fpm/conf.d | grep "snowflake"
    if (($? >= 1)); then
      run_process "   Installing snowflake" install_snowflake_nginx
      echo_with_color green "    Snowflake installed\n" >&5
    fi
  fi
else
  #fedora / centos
  ls /etc/php.d | grep "snowflake"
  if (($? >= 1)); then
    if ((CURRENT_OS == 7)); then
      # pdo_snowflake requires gcc 5.2 to install, centos7 only has 4.8 available
      echo_with_color red "Snowflake only supported on CentOS / RHEL 8. Skipping...\n" >&5
    else
      run_process "   Installing Snowflake" install_snowflake
      echo_with_color green "    snowflake installed\n" >&5
    fi
  fi
fi

### INSTALL Hive ODBC Driver
php -m | grep -E "^odbc"
if (($? >= 1)); then
  run_process "   Installing hive odbc" install_hive_odbc
  if ((HIVE_ODBC_INSTALLED != "odbc")); then
    echo_with_color red "\nCould not build hive odbc driver." >&5
  else
    echo_with_color green "    hive odbc installed\n" >&5
  fi
fi

### INSTALL Dremio ODBC Driver
php -m | grep -E "^odbc"
if (($? >= 1)); then
  run_process "   Installing dremio odbc" install_dremio_odbc
  if ((DREMIO_ODBC_INSTALLED != "odbc")); then
    echo_with_color red "\nCould not build dremio odbc driver." >&5
  else
    echo_with_color green "    dremio odbc installed\n" >&5
  fi
fi

### INSTALL Databricks ODBC Driver
php -m | grep -E "^odbc"
if (($? >= 1)); then
  run_process "   Installing databricks odbc" install_databricks_odbc
  if ((DATABRICKS_ODBC_INSTALLED != "odbc")); then
    echo_with_color red "\nCould not build databricks odbc driver." >&5
  else
    echo_with_color green "    databricks odbc installed\n" >&5
  fi
fi

### INSTALL SAP HANA ODBC Driver
php -m | grep -E "^odbc"
if (($? >= 1)); then
  run_process "   Installing SAP HANA odbc" install_hana_odbc
  if ((HANA_ODBC_INSTALLED != "odbc")); then
    echo_with_color red "\nCould not build SAP HANA odbc driver." >&5
  else
    echo_with_color green "    SAP HANA odbc installed\n" >&5
  fi
fi

### Configuring PHP OPCache and JIT compilation
run_process "   Configuring PHP OPCache and JIT compilation" enable_opcache

if [[ $APACHE == TRUE ]]; then
  if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
    service apache2 reload
  else
    #fedora / centos
    service httpd restart
  fi
else
  if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
    service ${PHP_VERSION}-fpm reload
  else
    #fedora / centos
    service php-fpm restart
  fi
fi
echo_with_color green "PHP Extensions configured.\n" >&5

### Step 5. Installing Composer
echo_with_color blue "Step 5: Installing Composer...\n" >&5
run_process "   Installing Composer" install_composer
echo_with_color green "Composer installed.\n" >&5

### Step 6. Installing MySQL
if [[ $MYSQL == TRUE ]]; then ### Only with key --with-mysql
  echo_with_color blue "Step 6: Installing System Database for DreamFactory...\n" >&5
  run_process "  Checking for existing MySqlDatabase" check_mysql_exists

  if ((CHECK_MYSQL_PROCESS == 0)) || ((CHECK_MYSQL_INSTALLATION == 0)) || ((CHECK_MYSQL_PORT == 0)); then
    echo_with_color red "MySQL Database detected in the system. Skipping installation. \n" >&5
    DB_FOUND=TRUE
  else
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      run_process "   Adding mariadb repo" add_mariadb_repo
      run_process "   Updating System" system_update
    fi
    echo_with_color magenta "Please choose a strong MySQL root user password: " >&5
    read -r -s DB_PASS
    if [[ -z $DB_PASS ]]; then
      until [[ -n $DB_PASS ]]; do
        echo_with_color red "The password can't be empty!" >&5
        read -r -s DB_PASS
      done
    fi
    echo_with_color green "\nPassword accepted.\n" >&5
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      # Disable interactive mode in installation mariadb. Set generated above password.
      export DEBIAN_FRONTEND="noninteractive"
      debconf-set-selections <<<"mariadb-server mysql-server/root_password password $DB_PASS"
      debconf-set-selections <<<"mariadb-server mysql-server/root_password_again password $DB_PASS"
    fi
    run_process "   Installing MariaDB" install_mariadb
  fi
  echo_with_color green "Database for DreamFactory installed.\n" >&5

  ### Step 7. Configuring DreamFactory system database
  echo_with_color blue "Step 7: Configure DreamFactory system database.\n" >&5

  DB_INSTALLED=FALSE

  # The MySQL database has already been installed, so let's configure
  # the DreamFactory system database.
  if [[ $DB_FOUND == TRUE ]]; then
    echo_with_color magenta "Is DreamFactory MySQL system database already configured? [Yy/Nn] " >&5
    read -r DB_ANSWER
    if [[ -z $DB_ANSWER ]]; then
      DB_ANSWER=Y
    fi
    if [[ $DB_ANSWER =~ ^[Yy]$ ]]; then
      DB_INSTALLED=TRUE
    # MySQL system database is not installed, but MySQL is, so let's
    # prompt the user for the root password.
    else
      echo_with_color magenta "\n Enter MySQL root password:  " >&5
      read -r DB_PASS

      # Test DB access
      mysql -h localhost -u root "-p$DB_PASS" -e"quit"
      if (($? >= 1)); then
        ACCESS=FALSE
        TRYS=0
        until [[ $ACCESS == TRUE ]]; do
          echo_with_color red "\nPassword incorrect!\n " >&5
          echo_with_color magenta "Enter root user password:\n " >&5
          read -r -s DB_PASS
          mysql -h localhost -u root "-p$DB_PASS" -e"quit"
          if (($? == 0)); then
            ACCESS=TRUE
          fi
          TRYS=$((TRYS + 1))
          if ((TRYS == 3)); then
            echo_with_color red "\nExit.\n" >&5
            exit 1
          fi
        done
      fi
    fi
  fi
  # If the DreamFactory system database not already installed,
  # let's install it.
  if [[ $DB_INSTALLED == FALSE ]]; then

    # Test DB access
    mysql -h localhost -u root "-p$DB_PASS" -e"quit"
    if (($? >= 1)); then
      echo_with_color red "Connection to Database failed. Exit \n" >&5
      exit 1
    fi
    echo_with_color magenta "\n What would you like to name your system database? (e.g. dreamfactory) " >&5
    read -r DF_SYSTEM_DB
    if [[ -z $DF_SYSTEM_DB ]]; then
      until [[ -n $DF_SYSTEM_DB ]]; do
        echo_with_color red "\nThe name can't be empty!" >&5
        read -r DF_SYSTEM_DB
      done
    fi

    echo "CREATE DATABASE ${DF_SYSTEM_DB};" | mysql -u root "-p${DB_PASS}" 2>&5
    if (($? >= 1)); then
      echo_with_color red "\nCreating database error. Exit" >&5
      exit 1
    fi
    echo_with_color magenta "\n Please create a MySQL DreamFactory system database user name (e.g. dfadmin): " >&5
    read -r DF_SYSTEM_DB_USER
    if [[ -z $DF_SYSTEM_DB_USER ]]; then
      until [[ -n $DF_SYSTEM_DB_USER ]]; do
        echo_with_color red "The name can't be empty!" >&5
        read -r DF_SYSTEM_DB_USER
      done
    fi
    echo_with_color magenta "\n Please create a secure MySQL DreamFactory system database user password: " >&5
    read -r -s DF_SYSTEM_DB_PASSWORD
    if [[ -z $DF_SYSTEM_DB_PASSWORD ]]; then
      until [[ -n $DF_SYSTEM_DB_PASSWORD ]]; do
        echo_with_color red "The password can't be empty!" >&5
        read -r -s DF_SYSTEM_DB_PASSWORD
      done
    fi
    # Generate password for user in DB
    echo "GRANT ALL PRIVILEGES ON ${DF_SYSTEM_DB}.* to \"${DF_SYSTEM_DB_USER}\"@\"localhost\" IDENTIFIED BY \"${DF_SYSTEM_DB_PASSWORD}\";" | mysql -u root "-p${DB_PASS}" 2>&5
    if (($? >= 1)); then
      echo_with_color red "\nCreating new user error. Exit" >&5
      exit 1
    fi
    echo "FLUSH PRIVILEGES;" | mysql -u root "-p${DB_PASS}"

    echo -e "\nDatabase configuration finished.\n" >&5
  else
    echo_with_color green "Skipping...\n" >&5
  fi
else
  echo_with_color green "Step 6: Skipping DreamFactory system database installation.\n" >&5
  echo_with_color green "Step 7: Skipping DreamFactory system database configuration.\n" >&5
fi

### Step 8. Install DreamFactory
echo_with_color blue "Step 8: Installing DreamFactory...\n " >&5

ls -d /opt/dreamfactory
if (($? >= 1)); then
  run_process "   Cloning DreamFactory repository" clone_dreamfactory_repository
else
  echo_with_color red "DreamFactory detected.\n" >&5
  DF_CLEAN_INSTALLATION=FALSE
fi

if [[ $DF_CLEAN_INSTALLATION == FALSE ]]; then
  ls /opt/dreamfactory/composer.{json,lock,json-dist}
  if (($? == 0)); then
    echo_with_color red "Would you like to upgrade your instance? [Yy/Nn]" >&5
    read -r LICENSE_FILE_ANSWER
    if [[ -z $LICENSE_FILE_ANSWER ]]; then
      LICENSE_FILE_ANSWER=N
    fi
    LICENSE_FILE_EXIST=TRUE
  fi
fi

if [[ $LICENSE_FILE_EXIST == TRUE ]]; then
  if [[ $LICENSE_FILE_ANSWER =~ ^[Yy]$ ]]; then
    echo_with_color magenta "\nEnter absolute path to license files, complete with trailing slash: [/]" >&5
    read -r LICENSE_PATH
    if [[ -z $LICENSE_PATH ]]; then
      LICENSE_PATH="."
    fi
    ls $LICENSE_PATH/composer.{json,lock,json-dist}
    if (($? >= 1)); then
      echo_with_color red "\nLicenses not found. Skipping.\n" >&5
    else
      cp $LICENSE_PATH/composer.{json,lock,json-dist} /opt/dreamfactory/
      LICENSE_INSTALLED=TRUE
      echo_with_color green "\nLicenses file installed. \n" >&5
      echo_with_color blue "Installing DreamFactory...\n" >&5
    fi
  else
    echo_with_color red "\nSkipping...\n" >&5
  fi
else
  echo_with_color magenta "Do you have a commercial DreamFactory license? [Yy/Nn] " >&5
  read -r LICENSE_FILE_ANSWER
  if [[ -z $LICENSE_FILE_ANSWER ]]; then
    LICENSE_FILE_ANSWER=N
  fi
  if [[ $LICENSE_FILE_ANSWER =~ ^[Yy]$ ]]; then
    echo_with_color magenta "\nEnter absolute path to license files, complete with trailing slash: [/]" >&5
    read -r LICENSE_PATH
    if [[ -z $LICENSE_PATH ]]; then
      LICENSE_PATH="."
    fi
    ls $LICENSE_PATH/composer.{json,lock,json-dist}
    if (($? >= 1)); then
      echo_with_color red "\nLicenses not found. Skipping.\n" >&5
      echo_with_color red "Installing DreamFactory OSS version...\n" >&5
    else
      cp $LICENSE_PATH/composer.{json,lock,json-dist} /opt/dreamfactory/
      LICENSE_INSTALLED=TRUE
      echo_with_color green "\nLicense files installed. \n" >&5
      echo_with_color blue "Installing DreamFactory...\n" >&5
    fi
  else
    echo_with_color red "\nInstalling DreamFactory OSS version.\n" >&5
  fi
fi

chown -R "$CURRENT_USER" /opt/dreamfactory && cd /opt/dreamfactory || exit 1

run_process "   Installing DreamFactory"  run_composer_install

### Shutdown silent mode because php artisan df:setup and df:env will get troubles with prompts.
exec 1>&5 5>&-

if [[ $DB_INSTALLED == FALSE ]]; then
  sudo -u "$CURRENT_USER" bash -c "php artisan df:env -q \
                --db_connection=mysql \
                --db_host=127.0.0.1 \
                --db_port=3306 \
                --db_database=${DF_SYSTEM_DB} \
                --db_username=${DF_SYSTEM_DB_USER} \
                --db_password=${DF_SYSTEM_DB_PASSWORD//\'/} \
                --db_install=Linux"
  sed -i 's/\#DB\_CHARSET\=/DB\_CHARSET\=utf8/g' .env
  sed -i 's/\#DB\_COLLATION\=/DB\_COLLATION\=utf8\_unicode\_ci/g' .env
  echo -e "\n"
  MYSQL_INSTALLED=TRUE

elif [[ ! $MYSQL == TRUE && $DF_CLEAN_INSTALLATION == TRUE ]] || [[ $DB_INSTALLED == TRUE ]]; then
  sudo -u "$CURRENT_USER" bash -c "php artisan df:env --df_install=Linux"
  if [[ $DB_INSTALLED == TRUE ]]; then
    sed -i 's/\#DB\_CHARSET\=/DB\_CHARSET\=utf8/g' .env
    sed -i 's/\#DB\_COLLATION\=/DB\_COLLATION\=utf8\_unicode\_ci/g' .env
  fi
fi

if [[ $DF_CLEAN_INSTALLATION == TRUE ]]; then
  sudo -u "$CURRENT_USER" bash -c "php artisan df:setup"
fi

if [[ $LICENSE_INSTALLED == TRUE || $DF_CLEAN_INSTALLATION == FALSE ]]; then
  php artisan migrate --seed
  sudo -u "$CURRENT_USER" bash -c "php artisan config:clear -q"

  if [[ $LICENSE_INSTALLED == TRUE ]]; then
    grep DF_LICENSE_KEY .env >/dev/null 2>&1 # Check for existing key.
    if (($? == 0)); then
      echo_with_color red "\nThe license key is already installed. Do you want to install a new key? [Yy/Nn]"
      read -r KEY_ANSWER
      if [[ -z $KEY_ANSWER ]]; then
        KEY_ANSWER=N
      fi
      NEW_KEY=TRUE
    fi

    if [[ $NEW_KEY == TRUE ]]; then
      if [[ $KEY_ANSWER =~ ^[Yy]$ ]]; then #Install new key
        CURRENT_KEY=$(grep DF_LICENSE_KEY .env)
        echo_with_color magenta "\nPlease provide your new license key:"
        read -r LICENSE_KEY
        size=${#LICENSE_KEY}
        if [[ -z $LICENSE_KEY ]]; then
          until [[ -n $LICENSE_KEY ]]; do
            echo_with_color red "\nThe field can't be empty!"
            read -r LICENSE_KEY
            size=${#LICENSE_KEY}
          done
        elif ((size != 32)); then
          until ((size == 32)); do
            echo_with_color red "\nInvalid License Key provided"
            echo_with_color magenta "\nPlease provide your license key:"
            read -r LICENSE_KEY
            size=${#LICENSE_KEY}
          done
        fi
        ###Change license key in .env file
        sed -i "s/$CURRENT_KEY/DF_LICENSE_KEY=$LICENSE_KEY/" .env
      else
        echo_with_color red "\nSkipping..." #Skip if key found in .env file and no need to update
      fi
    else
      echo_with_color magenta "\nPlease provide your license key:" #Install key if not found existing key.
      read -r LICENSE_KEY
      size=${#LICENSE_KEY}
      if [[ -z $LICENSE_KEY ]]; then
        until [[ -n $LICENSE_KEY ]]; do
          echo_with_color red "The field can't be empty!"
          read -r LICENSE_KEY
          size=${#LICENSE_KEY}
        done
      elif ((size != 32)); then
        until ((size == 32)); do
          echo_with_color red "\nInvalid License Key provided"
          echo_with_color magenta "\nPlease provide your license key:"
          read -r LICENSE_KEY
          size=${#LICENSE_KEY}
        done
      fi
      ###Add license key to .env file
      echo -e "\nDF_LICENSE_KEY=${LICENSE_KEY}" >>.env
    fi
  fi
fi

if [[ $APACHE == TRUE ]]; then
  chmod -R 2775 /opt/dreamfactory/
  if [[ $CURRENT_KERNEL == "debian" || $CURRENT_KERNEL == "ubuntu" ]]; then
    chown -R "www-data:$CURRENT_USER" /opt/dreamfactory/
  else
    chown -R "apache:$CURRENT_USER" /opt/dreamfactory/
  fi
fi

### Uncomment nodejs in .env file
grep -E "^#DF_NODEJS_PATH" .env >/dev/null
if (($? == 0)); then
  sed -i "s,\#DF_NODEJS_PATH=/usr/local/bin/node,DF_NODEJS_PATH=$NODE_PATH," .env
fi

### Ubuntu 20, centos8 and fedora uses the python2 command instead of python. So we need to update our .env
if [[ ! $CURRENT_KERNEL == "debian" ]]; then
  sed -i "s,\#DF_PYTHON_PATH=/usr/local/bin/python,DF_PYTHON_PATH=$(which python2)," .env
fi

sudo -u "$CURRENT_USER" bash -c "php artisan cache:clear -q"

#Add rules if SELinux enabled, redhat systems only
if [[ $CURRENT_KERNEL == "centos" || $CURRENT_KERNEL == "rhel" || $CURRENT_KERNEL == "fedora" ]]; then
  sestatus | grep SELinux | grep enabled >/dev/null
  if (($? == 0)); then
    setsebool -P httpd_can_network_connect_db 1
    chcon -t httpd_sys_content_t storage -R
    chcon -t httpd_sys_content_t bootstrap/cache/ -R
    chcon -t httpd_sys_rw_content_t storage -R
    chcon -t httpd_sys_rw_content_t bootstrap/cache/ -R
  fi
fi

### Add Permissions and Ownerships
if [[ ! $APACHE == TRUE ]]; then
  echo_with_color blue "Adding Permissions and Ownerships...\n"
  echo_with_color blue "    Creating user 'dreamfactory'"
  useradd dreamfactory
  if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
    PHP_VERSION_NUMBER=$(php --version 2>/dev/null | head -n 1 | cut -d " " -f 2 | cut -c 1,2,3)
  fi
  echo_with_color blue "    Updating php-fpm user, group, and owner"
  if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
    sed -i "s,www-data,dreamfactory," /etc/php/$PHP_VERSION_NUMBER/fpm/pool.d/www.conf
  else
    # centos, fedora
    sed -i "s,;listen.owner = nobody,listen.owner = dreamfactory," /etc/php-fpm.d/www.conf
    sed -i "s,;listen.group = nobody,listen.group = dreamfactory," /etc/php-fpm.d/www.conf
    sed -i "s,;listen.mode = 0660,listen.mode = 0660\nuser = dreamfactory\ngroup = dreamfactory," /etc/php-fpm.d/www.conf
    sed -i "s,listen.acl_users,;listen.acl_users," /etc/php-fpm.d/www.conf
  fi
  if (($? == 0)); then
    if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
      usermod -a -G dreamfactory www-data
    else
      # centos, fedora
      usermod -a -G dreamfactory nginx
    fi
    echo_with_color blue "    Changing ownership and permission of /opt/dreamfactory to 'dreamfactory' user"
    chown -R dreamfactory:dreamfactory /opt/dreamfactory
    chmod -R u=rwX,g=rX,o= /opt/dreamfactory
    echo_with_color blue "    Restarting nginx and php-fpm"
    service nginx restart
    if (($? >= 1)); then
      echo_with_color red "nginx failed to restart\n"
      exit 1
    else
      if [[ $CURRENT_KERNEL == "ubuntu" || $CURRENT_KERNEL == "debian" ]]; then
        service php$PHP_VERSION_NUMBER-fpm restart
      else
        # centos, fedora
        service php-fpm restart
      fi
      if (($? >= 1)); then
        echo_with_color red "php-fpm failed to restart\n"
        exit 1
      fi
      echo_with_color green "Done! Ownership and Permissions changed to user 'dreamfactory'\n"
    fi
  else
    echo_with_color red "Unable to update php-fpm www.conf file. Please check the file location of www.conf"
  fi
fi

echo_with_color green "Installation finished! DreamFactory has been installed in /opt/dreamfactory "

if [[ $DEBUG == TRUE ]]; then
  echo_with_color red "\nThe log file saved in: /tmp/dreamfactory_installer.log "
fi

### Summary table
if [[ $MYSQL_INSTALLED == TRUE ]]; then
  sed -i "s/\#DB\_CONNECTION\=sqlite/DB\_CONNECTION\=mysql/g" .env
  sed -i "s/\#DB\_HOST\=/DB\_HOST\=127.0.0.1/g" .env
  sed -i "s/\#DB\_PORT\=/DB\_PORT\=3306/g" .env
  sed -i "s/\#DB\_DATABASE\=/DB\_DATABASE\=$DF_SYSTEM_DB/g" .env
  sed -i "s/\#DB\_USERNAME\=/DB\_USERNAME\=$DF_SYSTEM_DB_USER/g" .env
  sed -i "s/\#DB\_PASSWORD\=/DB\_PASSWORD\=$DF_SYSTEM_DB_PASSWORD/g" .env

  echo -e "\n "
  echo_with_color magenta "******************************"
  echo -e " DB for system table: mysql "
  echo -e " DB host: 127.0.0.1         "
  echo -e " DB port: 3306              "
  if [[ ! $DB_FOUND == TRUE ]]; then
    echo -e " DB root password: $DB_PASS"
  fi
  echo -e " DB name: $DF_SYSTEM_DB"
  echo -e " DB user: $DF_SYSTEM_DB_USER"
  echo -e " DB password: $DF_SYSTEM_DB_PASSWORD"
  echo -e "******************************\n"
fi

exit 0
