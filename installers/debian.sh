#!/bin/bash
# Colors schemes for echo:
RD='\033[0;31m' # Red
GN='\033[0;32m' # Green
MG='\033[0;95m' # Magenta
NC='\033[0m'    # No Color

ERROR_STRING="Installation error. Exiting"
CURRENT_PATH=$(pwd)

DEFAULT_PHP_VERSION="php7.4"

CURRENT_OS=$(grep -e VERSION_ID /etc/os-release |
  sed -e 's/VERSION_ID="//g' |
  sed -e 's/\.[0-9]*"$//g' |
  sed -e 's/"$//g')

# CHECK FOR KEYS
while [[ -n $1 ]]; do
  case "$1" in
  --with-oracle) ORACLE=TRUE ;;
  --with-mysql) MYSQL=TRUE ;;
  --with-apache) APACHE=TRUE ;;
  --with-db2) DB2=TRUE ;;
  --with-cassandra) CASSANDRA=TRUE ;;
  --with-tag=*)
    DREAMFACTORY_VERSION_TAG="${1/--with-tag=/}"
    ;;
  --with-tag)
    DREAMFACTORY_VERSION_TAG="$2"
    shift
    ;;
  --debug) DEBUG=TRUE ;;
  --help) HELP=TRUE ;;
  -h) HELP=TRUE ;;
  *)
    echo -e "\n${RD}Invalid flag detected… aborting.${NC}"
    HELP=TRUE
    break
    ;;
  esac
  shift
done

if [[ $HELP == TRUE ]]; then
  echo -e "\nList of available keys:\n"
  echo "   --with-oracle                  Install driver and PHP extensions for work with Oracle DB"
  echo "   --with-mysql                   Install MariaDB as default system database for DreamFactory"
  echo "   --with-apache                  Install Apache2 web server for DreamFactory"
  echo "   --with-db2                     Install driver and PHP extensions for work with IBM DB2"
  echo "   --with-cassandra               Install driver and PHP extensions for work with Cassandra DB"
  echo "   --with-tag=<tag name>          Install DreamFactory with specific version.  "
  echo "   --debug                        Enable installation process logging to file in /tmp folder."
  echo -e "   -h, --help                     Show this help\n"
  exit 1
fi

if [[ ! $DEBUG == TRUE ]]; then
  exec 5>&1            # Save a copy of STDOUT
  exec >/dev/null 2>&1 # Redirect STDOUT to Null
else
  exec 5>&1 # Save a copy of STDOUT. Used because all echo redirects output to 5.
  exec >/tmp/dreamfactory_installer.log 2>&1
fi

clear >&5

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
  *)
    echo -e "${NC} $2 ${NC}"
    ;;
  esac
}

# Make sure script run as sudo
if ((EUID != 0)); then
  echo -e "${RD}\nPlease run script with root privileges: su -c \"bash $0\" \n${NC}" >&5
  exit 1
fi

# Retrieve executing user's username
CURRENT_USER=$(logname)

if [[ -z $SUDO_USER ]] && [[ -z $CURRENT_USER ]]; then
  echo_with_color red "Enter username for installation DreamFactory:" >&5
  read -r CURRENT_USER
  su "${CURRENT_USER}" -c "echo 'Checking user availability'" >&5
  if (($? >= 1)); then
    echo 'Please provide another user' >&5
    exit 1
  fi
fi

if [[ -n $SUDO_USER ]]; then
  CURRENT_USER=${SUDO_USER}
fi

### STEP 1. Install system dependencies
echo_with_color green "Step 1: Installing system dependencies...\n" >&5
apt-get update

if [[ ! -f "/etc/localtime" ]]; then
  echo -e "13\n33" | apt-get install -y tzdata
fi

apt-get install -y git \
  curl \
  wget \
  zip \
  unzip \
  ca-certificates \
  apt-transport-https \
  software-properties-common \
  lsof \
  libmcrypt-dev \
  libreadline-dev \
  dirmngr \
  wget \
  sudo

# Check installation status
if (($? >= 1)); then
  echo_with_color red "\n${ERROR_STRING}" >&5
  exit 1
fi

echo_with_color green "The system dependencies have been successfully installed.\n" >&5

### Step 2. Install PHP
echo_with_color green "Step 2: Installing PHP...\n" >&5

PHP_VERSION=${DEFAULT_PHP_VERSION}
PHP_VERSION_INDEX=$(echo $PHP_VERSION | cut -c 4-6)

# Install the php repository
curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -
add-apt-repository "deb https://packages.sury.org/php/ $(lsb_release -cs) main"

# Update the system
apt-get update

apt-get install -y ${PHP_VERSION}-common \
  ${PHP_VERSION}-xml \
  ${PHP_VERSION}-cli \
  ${PHP_VERSION}-curl \
  ${PHP_VERSION}-json \
  ${PHP_VERSION}-mysqlnd \
  ${PHP_VERSION}-sqlite \
  ${PHP_VERSION}-soap \
  ${PHP_VERSION}-mbstring \
  ${PHP_VERSION}-zip \
  ${PHP_VERSION}-bcmath \
  ${PHP_VERSION}-dev \
  ${PHP_VERSION}-ldap \
  ${PHP_VERSION}-pgsql \
  ${PHP_VERSION}-interbase \
  ${PHP_VERSION}-gd \
  ${PHP_VERSION}-sybase

if (($? >= 1)); then
  echo_with_color red "\n${ERROR_STRING}" >&5
  exit 1
fi

sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

echo_with_color green "PHP installed.\n" >&5

### Step 3. Install Apache
if [[ $APACHE == TRUE ]]; then ### Only with key --apache
  echo_with_color green "Step 3: Installing Apache...\n" >&5
  # Check Apache installation status
  ps aux | grep -v grep | grep apache2
  CHECK_APACHE_PROCESS=$?

  dpkg -l | grep apache2 | cut -d " " -f 3 | grep -E "apache2$"
  CHECK_APACHE_INSTALLATION=$?

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
      apt-get install -y apache2 libapache2-mod-${PHP_VERSION}
      if (($? >= 1)); then
        echo_with_color red "\nCould not install Apache. Exiting." >&5
        exit 1
      fi
      a2enmod rewrite
      echo "extension=pdo_sqlsrv.so" >>"/etc/php/${PHP_VERSION_INDEX}/apache2/conf.d/30-pdo_sqlsrv.ini"
      echo "extension=sqlsrv.so" >>"/etc/php/${PHP_VERSION_INDEX}/apache2/conf.d/20-sqlsrv.ini"
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
    </Directory>
</VirtualHost>" >/etc/apache2/sites-available/000-default.conf

      service apache2 restart

      echo_with_color green "Apache2 installed.\n" >&5
    fi
  fi

else
  echo_with_color green "Step 3: Installing Nginx...\n" >&5 ### Default choice

  # Check nginx installation in the system
  ps aux | grep -v grep | grep nginx
  CHECK_NGINX_PROCESS=$?

  dpkg -l | grep nginx | cut -d " " -f 3 | grep -E "nginx$"
  CHECK_NGINX_INSTALLATION=$?

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
      apt-get install -y nginx ${PHP_VERSION}-fpm
      if (($? >= 1)); then
        echo_with_color red "\nCould not install Nginx. Exiting." >&5
        exit 1
      fi
      # Change php fpm configuration file
      sed -i 's/\;cgi\.fix\_pathinfo\=1/cgi\.fix\_pathinfo\=0/' "$(php -i | sed -n '/^Loaded Configuration File => /{s:^.*> ::;p;}' | sed 's/cli/fpm/')"

      # Create nginx site entry
      echo "
server {

  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;
  root /opt/dreamfactory/public;
  index index.php index.html index.htm;
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

    try_files  \$uri rewrite ^ /index.php?\$query_string;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/${PHP_VERSION}-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
  }
}" >/etc/nginx/sites-available/default

      service ${PHP_VERSION}-fpm restart && service nginx restart

      echo_with_color green "Nginx installed.\n" >&5
    fi
  fi
fi

### Step 4. Configure PHP development tools
echo_with_color green "Step 4: Configuring PHP Extensions...\n" >&5

apt-get install -y php-pear

if (($? >= 1)); then
  echo_with_color red "\n${ERROR_STRING}" >&5
  exit 1
fi

pecl channel-update pecl.php.net

### Install MCrypt
php -m | grep -E "^mcrypt"
if (($? >= 1)); then
  printf "\n" | pecl install mcrypt-1.0.4
  if (($? >= 1)); then
    echo_with_color red "\nMcrypt extension installation error." >&5
    exit 1
  fi
  echo "extension=mcrypt.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/mcrypt.ini"
  phpenmod -s ALL mcrypt
  php -m | grep -E "^mcrypt"
  if (($? >= 1)); then
    echo_with_color red "\nMcrypt installation error." >&5
  fi
fi

### Install MongoDB drivers
php -m | grep -E "^mongodb"
if (($? >= 1)); then
  pecl install mongodb
  if (($? >= 1)); then
    echo_with_color red "\nMongo DB extension installation error." >&5
    exit 1
  fi
  echo "extension=mongodb.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/mongodb.ini"
  phpenmod -s ALL mongodb
  php -m | grep -E "^mongodb"
  if (($? >= 1)); then
    echo_with_color red "\nMongoDB installation error." >&5
  fi
fi

### Install MS SQL Drivers
php -m | grep -E "^sqlsrv"
if (($? >= 1)); then
  curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
  case $CURRENT_OS in

  8)
    curl https://packages.microsoft.com/config/debian/8/prod.list >/etc/apt/sources.list.d/mssql-release.list
    ;;

  9)
    curl https://packages.microsoft.com/config/debian/9/prod.list >/etc/apt/sources.list.d/mssql-release.list
    ;;

  10)
    curl https://packages.microsoft.com/config/debian/10/prod.list >/etc/apt/sources.list.d/mssql-release.list
    ;;

  *)
    echo_with_color red "The script support only Debian 8, 9, and 10 versions. Exit.\n " >&5
    exit 1
    ;;
  esac
  apt-get update
  ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools unixodbc-dev

  pecl install sqlsrv
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
    exit 1
  fi
  echo "extension=sqlsrv.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/sqlsrv.ini"
  phpenmod -s ALL sqlsrv
  php -m | grep -E "^sqlsrv"
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
  fi
fi

### DRIVERS FOR MSSQL (pdo_sqlsrv)
php -m | grep -E "^pdo_sqlsrv"
if (($? >= 1)); then
  pecl install pdo_sqlsrv
  if (($? >= 1)); then
    echo_with_color red "\npdo_sqlsrv extension installation error." >&5
    exit 1
  fi
  echo "extension=pdo_sqlsrv.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/pdo_sqlsrv.ini"
  phpenmod -s ALL pdo_sqlsrv
  php -m | grep -E "^pdo_sqlsrv"
  if (($? >= 1)); then
    echo_with_color red "\nCould not install pdo_sqlsrv extension" >&5
  fi
fi

### DRIVERS FOR ORACLE ( ONLY WITH KEY --with-oracle )
php -m | grep -E "^oci8"
if (($? >= 1)); then
  if [[ $ORACLE == TRUE ]]; then
    echo_with_color magenta "Enter absolute path to the Oracle drivers, complete with trailing slash: [./] " >&5
    read -r DRIVERS_PATH
    if [[ -z $DRIVERS_PATH ]]; then
      DRIVERS_PATH="."
    fi
    unzip "$DRIVERS_PATH/instantclient-*.zip" -d /opt/oracle
    if (($? == 0)); then
      echo_with_color green "Drivers found.\n" >&5
      apt install -y libaio1
      echo "/opt/oracle/instantclient_19_5" >/etc/ld.so.conf.d/oracle-instantclient.conf
      ldconfig
      printf "instantclient,/opt/oracle/instantclient_19_5\n" | pecl install oci8
      if (($? >= 1)); then
        echo_with_color red "\nOracle instant client installation error" >&5
        exit 1
      fi
      echo "extension=oci8.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/oci8.ini"
      phpenmod -s ALL oci8

      php -m | grep oci8
      if (($? >= 1)); then
        echo_with_color red "\nCould not install oci8 extension." >&5
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
    echo_with_color magenta "Enter absolute path to the IBM DB2 drivers, complete with trailing slash: [./] " >&5
    read -r DRIVERS_PATH
    if [[ -z $DRIVERS_PATH ]]; then
      DRIVERS_PATH="."
    fi
    tar xzf $DRIVERS_PATH/ibm_data_server_driver_package_linuxx64_v11.5.tar.gz -C /opt/
    if (($? == 0)); then
      echo_with_color green "Drivers found.\n" >&5
      apt install -y ksh
      chmod +x /opt/dsdriver/installDSDriver
      /usr/bin/ksh /opt/dsdriver/installDSDriver
      ln -s /opt/dsdriver/include /include
      git clone https://github.com/dreamfactorysoftware/PDO_IBM-1.3.4-patched.git /opt/PDO_IBM-1.3.4-patched
      cd /opt/PDO_IBM-1.3.4-patched/ || exit 1
      phpize
      ./configure --with-pdo-ibm=/opt/dsdriver/lib
      make && make install
      if (($? >= 1)); then
        echo_with_color red "\nCould not make pdo_ibm extension." >&5
        exit 1
      fi
      echo "extension=pdo_ibm.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/pdo_ibm.ini"
      phpenmod -s ALL pdo_ibm
      php -m | grep pdo_ibm
      if (($? >= 1)); then
        echo_with_color red "\nCould not install pdo_ibm extension." >&5
      else
        ### DRIVERS FOR IBM DB2 ( ONLY WITH KEY --with-db2 )
        php -m | grep -E "^ibm_db2"
        if (($? >= 1)); then
          printf "/opt/dsdriver/ \n" | pecl install ibm_db2
          if (($? >= 1)); then
            echo_with_color red "\nibm_db2 extension installation error." >&5
            exit 1
          fi
          echo "extension=ibm_db2.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/ibm_db2.ini"
          phpenmod -s ALL ibm_db2
          php -m | grep ibm_db2
          if (($? >= 1)); then
            echo_with_color red "\nCould not install ibm_db2 extension." >&5
          fi
        fi
      fi
    else
      echo_with_color red "Drivers not found. Skipping...\n" >&5
    fi
    unset DRIVERS_PATH
    cd "$CURRENT_PATH" || exit 1
    rm -rf /opt/PDO_IBM-1.3.4-patched
  fi
fi

### DRIVERS FOR CASSANDRA ( ONLY WITH KEY --with-cassandra )
php -m | grep -E "^cassandra"
if (($? >= 1)); then
  if [[ $CASSANDRA == TRUE ]]; then
    apt install -y cmake libgmp-dev
    git clone https://github.com/datastax/php-driver.git /opt/cassandra
    cd /opt/cassandra/ || exit 1
    git checkout v1.3.2 && git pull origin v1.3.2
    if ((CURRENT_OS == 8)); then
      wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/cassandra/v2.10.0/cassandra-cpp-driver_2.10.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/cassandra/v2.10.0/cassandra-cpp-driver-dbg_2.10.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/cassandra/v2.10.0/cassandra-cpp-driver-dev_2.10.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.23.0/libuv1-dbg_1.23.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.23.0/libuv1-dev_1.23.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.23.0/libuv1_1.23.0-1_amd64.deb
      dpkg -i *.deb
      if (($? >= 1)); then
        echo_with_color red "\ncassandra extension installation error." >&5
        exit 1
      fi
    else
      wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/cassandra/v2.10.0/cassandra-cpp-driver-dbg_2.10.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/cassandra/v2.10.0/cassandra-cpp-driver-dev_2.10.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/cassandra/v2.10.0/cassandra-cpp-driver_2.10.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/dependencies/libuv/v1.23.0/libuv1-dbg_1.23.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/dependencies/libuv/v1.23.0/libuv1-dev_1.23.0-1_amd64.deb
      wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/dependencies/libuv/v1.23.0/libuv1_1.23.0-1_amd64.deb
      dpkg -i *.deb
      if (($? >= 1)); then
        echo_with_color red "\ncassandra extension installation error." >&5
        exit 1
      fi
    fi
    sed -i "s/7.1.99/7.2.99/" ./ext/package.xml
    pecl install ./ext/package.xml
    if (($? >= 1)); then
      echo_with_color red "\ncassandra extension installation error." >&5
      exit 1
    fi
    echo "extension=cassandra.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/cassandra.ini"
    phpenmod -s ALL cassandra
    php -m | grep cassandra
    if (($? >= 1)); then
      echo_with_color red "\nCould not install ibm_db2 extension." >&5
    fi
    cd "$CURRENT_PATH" || exit 1
    rm -rf /opt/cassandra
  fi
fi

### INSTALL IGBINARY EXT.
php -m | grep -E "^igbinary"
if (($? >= 1)); then
  pecl install igbinary
  if (($? >= 1)); then
    echo_with_color red "\nigbinary extension installation error." >&5
    exit 1
  fi

  echo "extension=igbinary.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/igbinary.ini"
  phpenmod -s ALL igbinary
  php -m | grep igbinary
  if (($? >= 1)); then
    echo_with_color red "\nCould not install ibm_db2 extension." >&5
  fi
fi

### INSTALL PYTHON BUNCH
apt install -y python python-pip
pip list | grep bunch
if (($? >= 1)); then
  pip install bunch
  if (($? >= 1)); then
    echo_with_color red "\nCould not install python bunch extension." >&5
  fi
fi

### INSTALL PYTHON3 MUNCH
apt install -y python3 python3-pip
pip3 list | grep munch
if (($? >= 1)); then
  pip3 install munch
  if (($? >= 1)); then
    echo_with_color red "\nCould not install python3 munch extension." >&5
  fi
fi

### Install Node.js
node -v
if (($? >= 1)); then
  curl -sL https://deb.nodesource.com/setup_10.x | bash -
  apt-get install -y nodejs
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    exit 1
  fi
  NODE_PATH=$(whereis node | cut -d" " -f2)
fi

### INSTALL PCS
php -m | grep -E "^pcs"
if (($? >= 1)); then
  pecl install pcs-1.3.7
  if (($? >= 1)); then
    echo_with_color red "\npcs extension installation error.." >&5
    exit 1
  fi
  echo "extension=pcs.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/pcs.ini"
  phpenmod -s ALL pcs
  php -m | grep pcs
  if (($? >= 1)); then
    echo_with_color red "\nCould not install pcs extension." >&5
  fi
fi

### INSTALL COUCHBASE
# We are in the process of upgrading this to SDK 3, therefor is currently not working and commented out
# php -m | grep -E "^couchbase"
# if (($? >= 1)); then
#   if ((CURRENT_OS == 8)); then
#     wget -P /tmp http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-4-amd64.deb
#     dpkg -i /tmp/couchbase-release-1.0-4-amd64.deb

#   elif ((CURRENT_OS == 9 || CURRENT_OS == 10)); then
#     wget -O - https://packages.couchbase.com/clients/c/repos/deb/couchbase.key | apt-key add -
#     echo "deb https://packages.couchbase.com/clients/c/repos/deb/ubuntu1804 bionic bionic/main" >/etc/apt/sources.list.d/couchbase.list
#   fi

#   apt-get update
#   apt install -y libcouchbase3 libcouchbase-dev libcouchbase3-tools libcouchbase-dbg libcouchbase3-libev libcouchbase3-libevent zlib1g-dev
#   pecl install couchbase-3.1.2
#   if (($? >= 1)); then
#     echo_with_color red "\ncouchbase extension installation error." >&5
#     exit 1
#   fi
#   echo "extension=couchbase.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/xcouchbase.ini"
#   phpenmod -s ALL xcouchbase
#   php -m | grep couchbase
#   if (($? >= 1)); then
#     echo_with_color red "\nCould not install couchbase extension." >&5
#   fi
#   rm /etc/apt/sources.list.d/couchbase.list
# fi

### INSTALL Snowlake

if [[ $APACHE == TRUE ]]; then ### Only with key --apache
  ls /etc/php/${PHP_VERSION_INDEX}/apache2/conf.d | grep "snowflake"
  if (($? >= 1)); then
    apt-get update
    apt-get install -y --no-install-recommends --allow-unauthenticated gcc cmake ${PHP_VERSION}-pdo ${PHP_VERSION}-json ${PHP_VERSION}-dev
    git clone https://github.com/snowflakedb/pdo_snowflake.git /src/snowflake
    cd /src/snowflake
    export PHP_HOME=/usr
    /src/snowflake/scripts/build_pdo_snowflake.sh
    SNOWFLAKE_BUILD=$($PHP_HOME/bin/php -dextension=modules/pdo_snowflake.so -m | grep pdo_snowflake)
    if ((SNOWFLAKE_BUILD == 'pdo_snowflake')); then
      export PHP_HOME=/usr
      PHP_EXTENSION_DIR=$($PHP_HOME/bin/php -i | grep '^extension_dir' | sed 's/.*=>\(.*\).*/\1/')
      cp /src/snowflake/modules/pdo_snowflake.so $PHP_EXTENSION_DIR
      cp /src/snowflake/libsnowflakeclient/cacert.pem /etc/php/${PHP_VERSION_INDEX}/apache2/conf.d
      if (($? >= 1)); then
        echo_with_color red "\npdo_snowflake driver installation error." >&5
        exit 1
      fi
      echo -e "extension=pdo_snowflake.so\n\npdo_snowflake.cacert=/etc/php/${PHP_VERSION_INDEX}/apache2/conf.d/cacert.pem" >/etc/php/${PHP_VERSION_INDEX}/apache2/conf.d/20-pdo_snowflake.ini
    else
      echo_with_color red "\nCould not build pdo_snowflake driver." >&5
      exit 1
    fi
  fi

else
  ls /etc/php/${PHP_VERSION_INDEX}/fpm/conf.d | grep "snowflake"
  if (($? >= 1)); then
    apt-get update
    apt-get install -y --no-install-recommends --allow-unauthenticated gcc cmake ${PHP_VERSION}-pdo ${PHP_VERSION}-json ${PHP_VERSION}-dev
    git clone https://github.com/snowflakedb/pdo_snowflake.git /src/snowflake
    cd /src/snowflake
    export PHP_HOME=/usr
    /src/snowflake/scripts/build_pdo_snowflake.sh
    SNOWFLAKE_BUILD=$($PHP_HOME/bin/php -dextension=modules/pdo_snowflake.so -m | grep pdo_snowflake)
    if ((SNOWFLAKE_BUILD == 'pdo_snowflake')); then
      export PHP_HOME=/usr
      PHP_EXTENSION_DIR=$($PHP_HOME/bin/php -i | grep '^extension_dir' | sed 's/.*=>\(.*\).*/\1/')
      cp /src/snowflake/modules/pdo_snowflake.so $PHP_EXTENSION_DIR
      cp /src/snowflake/libsnowflakeclient/cacert.pem /etc/php/${PHP_VERSION_INDEX}/fpm/conf.d
      if (($? >= 1)); then
        echo_with_color red "\npdo_snowflake driver installation error." >&5
        exit 1
      fi
      echo -e "extension=pdo_snowflake.so\n\npdo_snowflake.cacert=/etc/php/${PHP_VERSION_INDEX}/fpm/conf.d/cacert.pem" >/etc/php/${PHP_VERSION_INDEX}/fpm/conf.d/20-pdo_snowflake.ini
    else
      echo_with_color red "\nCould not build pdo_snowflake driver." >&5
      exit 1
    fi
  fi
fi

### INSTALL Hive ODBC Driver
php -m | grep -E "^odbc"
if (($? >= 1)); then
  apt-get update
  apt-get install -y --no-install-recommends --allow-unauthenticated ${PHP_VERSION}-odbc
  mkdir /opt/hive
  cd /opt/hive
  curl --fail -O https://odbc-drivers.s3.amazonaws.com/apache-hive/maprhiveodbc_2.6.1.1001-2_amd64.deb
  dpkg -i maprhiveodbc_2.6.1.1001-2_amd64.deb
  test -f /opt/mapr/hiveodbc/lib/64/libmaprhiveodbc64.so
  rm maprhiveodbc_2.6.1.1001-2_amd64.deb
  export HIVE_SERVER_ODBC_DRIVER_PATH=/opt/mapr/hiveodbc/lib/64/libmaprhiveodbc64.so
  HIVE_ODBC_INSTALLED = $(php -m | grep -E "^odbc")
  if ((HIVE_ODBC_INSTALLED != "odbc")); then
    echo_with_color red "\nCould not build hive odbc driver." >&5
  fi
fi

if [[ $APACHE == TRUE ]]; then
  service apache2 reload
else
  service ${PHP_VERSION}-fpm reload
fi

echo_with_color green "PHP Extensions configured.\n" >&5

### Step 5. Installing Composer
echo_with_color green "Step 5: Installing Composer...\n" >&5

curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php

php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

if (($? >= 1)); then
  echo_with_color red "\n${ERROR_STRING}" >&5
  exit 1
fi
echo_with_color green "Composer installed.\n" >&5

### Step 6. Installing MySQL
if [[ $MYSQL == TRUE ]]; then ### Only with key --with-mysql
  echo_with_color green "Step 6: Installing System Database for DreamFactory...\n" >&5

  dpkg -l | grep mysql | cut -d " " -f 3 | grep -E "^mysql" | grep -E -v "^mysql-client"
  CHECK_MYSQL_INSTALLATION=$?

  ps aux | grep -v grep | grep -E "^mysql"
  CHECK_MYSQL_PROCESS=$?

  lsof -i :3306 | grep LISTEN
  CHECK_MYSQL_PORT=$?

  if ((CHECK_MYSQL_PROCESS == 0)) || ((CHECK_MYSQL_INSTALLATION == 0)) || ((CHECK_MYSQL_PORT == 0)); then
    echo_with_color red "MySQL Database detected in the system. Skipping installation. \n" >&5
    DB_FOUND=TRUE
  else
    if ((CURRENT_OS == 8)); then
      apt-key adv --no-tty --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
      add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/debian jessie main'

    elif ((CURRENT_OS == 9 || CURRENT_OS == 10)); then
      apt-key adv --no-tty --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
      add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/debian stretch main'

    else
      echo_with_color red "The script support only Debian 8, 9, and 10 versions. Exit.\n" >&5
      exit 1
    fi

    apt-get update

    echo_with_color magenta "Please choose a strong MySQL root user password: " >&5
    read -r DB_PASS
    if [[ -z $DB_PASS ]]; then
      until [[ -n $DB_PASS ]]; do
        echo_with_color red "The password can't be empty!" >&5
        read -r DB_PASS
      done
    fi

    echo_with_color green "\nPassword accepted.\n" >&5
    # Disable interactive mode in installation mariadb. Set generated above password.
    export DEBIAN_FRONTEND="noninteractive"
    debconf-set-selections <<<"mariadb-server mysql-server/root_password password $DB_PASS"
    debconf-set-selections <<<"mariadb-server mysql-server/root_password_again password $DB_PASS"

    apt-get install -y mariadb-server

    if (($? >= 1)); then
      echo_with_color red "\n${ERROR_STRING}" >&5
      exit 1
    fi

    service mariadb start
    if (($? >= 1)); then
      service mysql start
      if (($? >= 1)); then
        echo_with_color red "\nCould not start MariaDB.. Exit " >&5
        exit 1
      fi
    fi
  fi

  echo_with_color green "Database for DreamFactory installed.\n" >&5

  ### Step 7. Configuring DreamFactory system database
  echo_with_color green "Step 7: Configure DreamFactory system database.\n" >&5

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
      echo_with_color magenta "\nEnter MySQL root password:  " >&5
      read -r DB_PASS

      # Test DB access
      mysql -h localhost -u root "-p$DB_PASS" -e"quit"
      if (($? >= 1)); then
        ACCESS=FALSE
        TRYS=0
        until [[ $ACCESS == TRUE ]]; do
          echo_with_color red "\nPassword incorrect!\n " >&5
          echo_with_color magenta "Enter root user password:\n " >&5
          read -r DB_PASS
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
    echo_with_color magenta "\nWhat would you like to name your system database? (e.g. dreamfactory) " >&5
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
    echo_with_color magenta "\nPlease create a MySQL DreamFactory system database user name (e.g. dfadmin): " >&5
    read -r DF_SYSTEM_DB_USER
    if [[ -z $DF_SYSTEM_DB_USER ]]; then
      until [[ -n $DF_SYSTEM_DB_USER ]]; do
        echo_with_color red "The name can't be empty!" >&5
        read -r DF_SYSTEM_DB_USER
      done
    fi

    echo_with_color magenta "\nPlease create a secure MySQL DreamFactory system database user password: " >&5
    read -r DF_SYSTEM_DB_PASSWORD
    if [[ -z $DF_SYSTEM_DB_PASSWORD ]]; then
      until [[ -n $DF_SYSTEM_DB_PASSWORD ]]; do
        echo_with_color red "The name can't be empty!" >&5
        read -r DF_SYSTEM_DB_PASSWORD
      done
    fi
    # Generate password for user in DB
    echo "GRANT ALL PRIVILEGES ON ${DF_SYSTEM_DB}.* to \"${DF_SYSTEM_DB_USER}\"@\"localhost\" IDENTIFIED BY \"${DF_SYSTEM_DB_PASSWORD}\";" | mysql -u root "-p${DB_PASS}" 2>&5
    if (($? >= 1)); then
      echo_with_color red "\nCreating new user error. Exit" >&5
      exit 1
    fi

    echo "FLUSH PRIVILEGES;" | mysql -u root "-p${DB_PASS}"

    echo_with_color green "\nDatabase configuration finished.\n" >&5
  else
    echo_with_color green "Skipping...\n" >&5
  fi
else
  echo_with_color green "Step 6: Skipping DreamFactory system database installation.\n" >&5
  echo_with_color green "Step 7: Skipping DreamFactory system database configuration.\n" >&5
fi

### Step 8. Install DreamFactory
echo_with_color green "Step 8: Installing DreamFactory...\n " >&5

ls -d /opt/dreamfactory
if (($? >= 1)); then
  mkdir -p /opt/dreamfactory
  if [[ -z "${DREAMFACTORY_VERSION_TAG}" ]]; then
    git clone -b master --single-branch https://github.com/dreamfactorysoftware/dreamfactory.git /opt/dreamfactory
  else
    git clone -b "${DREAMFACTORY_VERSION_TAG}" --single-branch https://github.com/dreamfactorysoftware/dreamfactory.git /opt/dreamfactory
  fi
  if (($? >= 1)); then
    echo_with_color red "\nCould not clone DreamFactory repository. Exiting. " >&5
    exit 1
  fi
  DF_CLEAN_INSTALLATION=TRUE
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
    echo_with_color magenta "\nEnter absolute path to license files, complete with trailing slash: [./]" >&5
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
      echo_with_color green "Installing DreamFactory...\n" >&5
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
    echo_with_color magenta "\nEnter absolute path to license files, complete with trailing slash: [./]" >&5
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
      echo_with_color green "\nLicenses file installed. \n" >&5
      echo_with_color green "Installing DreamFactory...\n" >&5
    fi
  else
    echo_with_color red "\nInstalling DreamFactory OSS version.\n" >&5
  fi

fi

chown -R "$CURRENT_USER" /opt/dreamfactory && cd /opt/dreamfactory || exit 1

# If Oracle is not installed, add the --ignore-platform-reqs option
# to composer command
if [[ $ORACLE == TRUE ]]; then
  su "$CURRENT_USER" -c "/usr/local/bin/composer install --no-dev"
else
  su "$CURRENT_USER" -c "/usr/local/bin/composer install --no-dev --ignore-platform-reqs"
fi

### Shutdown silent mode because php artisan df:setup and df:env will get troubles with prompts.
exec 1>&5 5>&-

if [[ $DB_INSTALLED == FALSE ]]; then
  su "$CURRENT_USER" -c "php artisan df:env -q \
                --db_connection=mysql \
                --db_host=127.0.0.1 \
                --db_port=3306 \
                --db_database=${DF_SYSTEM_DB} \
                --db_username=${DF_SYSTEM_DB_USER} \
                --db_password=${DF_SYSTEM_DB_PASSWORD//\'/}"
  sed -i 's/\#DB\_CHARSET\=/DB\_CHARSET\=utf8/g' .env
  sed -i 's/\#DB\_COLLATION\=/DB\_COLLATION\=utf8\_unicode\_ci/g' .env
  echo -e "\n"
  MYSQL_INSTALLED=TRUE

elif [[ ! $MYSQL == TRUE && $DF_CLEAN_INSTALLATION == TRUE ]] || [[ $DB_INSTALLED == TRUE ]]; then
  su "$CURRENT_USER" -c "php artisan df:env"
  if [[ $DB_INSTALLED == TRUE ]]; then
    sed -i 's/\#DB\_CHARSET\=/DB\_CHARSET\=utf8/g' .env
    sed -i 's/\#DB\_COLLATION\=/DB\_COLLATION\=utf8\_unicode\_ci/g' .env
  fi
fi

if [[ $DF_CLEAN_INSTALLATION == TRUE ]]; then
  su "$CURRENT_USER" -c "php artisan df:setup"
fi

if [[ $LICENSE_INSTALLED == TRUE || $DF_CLEAN_INSTALLATION == FALSE ]]; then
  php artisan migrate --seed
  su "$CURRENT_USER" -c "php artisan config:clear -q"

  if [[ $LICENSE_INSTALLED == TRUE ]]; then
    grep DF_LICENSE_KEY .env >/dev/null 2>&1 # Check for existing key.
    if (($? == 0)); then
      echo_with_color red "\nThe license key already installed. Do you want to install a new key? [Yy/Nn]"
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
          read -r -r LICENSE_KEY
          size=${#LICENSE_KEY}
        done
      elif ((size != 32)); then
        until ((size == 32)); do
          echo_with_color red "\nInvalid License Key provided"
          echo_with_color magenta "\nPlease provide your license key:"
          read -r -r LICENSE_KEY
          size=${#LICENSE_KEY}
        done
      fi
      ###Add license key to .env file
      echo -e "\nDF_LICENSE_KEY=${LICENSE_KEY}" >>.env

    fi
  fi
fi

chmod -R 2775 /opt/dreamfactory/
chown -R "www-data:$CURRENT_USER" /opt/dreamfactory/

### Uncomment nodejs in .env file
grep -E "^#DF_NODEJS_PATH" .env >/dev/null
if (($? == 0)); then
  sed -i "s,\#DF_NODEJS_PATH=/usr/local/bin/node,DF_NODEJS_PATH=$NODE_PATH," .env
fi

su "$CURRENT_USER" -c "php artisan cache:clear -q"
echo_with_color green "\nInstallation finished! "

if [[ $DEBUG == TRUE ]]; then
  echo_with_color red "\nThe log file saved in: /tmp/dreamfactory_installer.log "

fi
### Summary table
if [[ $MYSQL_INSTALLED == TRUE ]]; then
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
  echo -e "******************************\n${NC}"
fi

exit 0
