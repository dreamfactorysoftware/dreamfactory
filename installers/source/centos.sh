#!/bin/bash

### INSTALLER FUNCTIONS

# We will use these to run each step of the installer inside run_process which will provide us with a
# progress bar while things are going.

system_update () {
  if ((CURRENT_OS == 7)); then
    yum update -y
  else
    # centos 8
    dnf update -y
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
    #centos 8
    dnf install -y git \
      curl \
      zip \
      unzip \
      ca-certificates \
      lsof \
      readline-devel \
      libzip-devel \
      wget
  fi
  # Check installation status
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi
}

install_php () {
  # Install the php repository
  if ((CURRENT_OS == 7)); then
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

    yum-config-manager --enable remi-php83

    #Install PHP
    yum --enablerepo=remi-php83 install -y php-common \
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
  else
    # RHEL 8
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-8.rpm

    dnf module list -y
    dnf module reset php -y
    dnf module enable php:remi-8.3 -y

    #Install PHP
    dnf install -y php-common \
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
  fi

  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi
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
  service httpd restart
  systemctl enable httpd.service
  firewall-cmd --add-service=http
}

check_nginx_installation_status() {
  ps aux | grep -v grep | grep nginx
  CHECK_NGINX_PROCESS=$?

  yum list installed | grep -E "^nginx.x86_64"
  CHECK_NGINX_INSTALLATION=$?
}

install_nginx () {
  if ((CURRENT_OS == 7)); then
    yum --enablerepo=remi-php83 install -y php-fpm nginx
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

  # RHEL8 php-fpm seems to default to a unix socket, rather than an ip (in RHEL7). As a result
  # fastcgi_pass has been changed from 127.0.0.1 to unix:/var/run/php-fpm/www.sock for RHEL / CENTOS 8 installation.
  if ((CURRENT_OS == 8)); then
  sed -i "s,127.0.0.1:9000;,unix:/var/run/php-fpm/www.sock;," /etc/nginx/conf.d/dreamfactory.conf
  useradd -r nginx
  fi

  #Need to remove default entry in nginx.conf
  grep default_server /etc/nginx/nginx.conf
  if (($? == 0)); then
    sed -i "s/default_server//g" /etc/nginx/nginx.conf
  fi
}

restart_nginx () {
  service php-fpm restart && service nginx restart
  systemctl enable nginx.service && systemctl enable php-fpm.service
  firewall-cmd --add-service=http
}

install_php_pear () {
  if ((CURRENT_OS == 7)); then
    yum --enablerepo=remi-php83 install -y php-pear
  else
    dnf install -y php-pear
  fi

  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi

  pecl channel-update pecl.php.net
}

install_mcrypt () {
  if ((CURRENT_OS == 7)); then
    yum --enablerepo=remi-php83 install -y libmcrypt-devel
  else
    dnf install -y libmcrypt-devel
  fi

  printf "\n" | pecl install mcrypt-1.0.5
  if (($? >= 1)); then
    echo_with_color red "\nMcrypt extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=mcrypt.so" >/etc/php.d/20-mcrypt.ini
}

install_mongodb () {
  pecl install mongodb <<<'no'
  if (($? >= 1)); then
    echo_with_color red "\nMongo DB extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=mongodb.so" >/etc/php.d/20-mongodb.ini
}

install_sql_server () {
  curl https://packages.microsoft.com/config/rhel/7/prod.repo >/etc/yum.repos.d/mssql-release.repo
  yum remove unixODBC-utf16 unixODBC-utf16-devel unixODBC-utf17 unixODBC-utf17-devel
  ACCEPT_EULA=Y yum install -y msodbcsql18 mssql-tools
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
    kill $!
    exit 1
  fi

  if ((CURRENT_OS == 7)); then
    yum install -y unixODBC-devel-2.3.1
  else
    yum install -y unixODBC-devel-2.3.7
  fi

  pecl install sqlsrv
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=sqlsrv.so" >/etc/php.d/20-sqlsrv.ini
}

install_pdo_sqlsrv () {
  pecl install pdo_sqlsrv-5.10.1
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=pdo_sqlsrv.so" >/etc/php.d/20-pdo_sqlsrv.ini
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
  pecl install igbinary
  if (($? >= 1)); then
    echo_with_color red "\nigbinary extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=igbinary.so" >/etc/php.d/20-igbinary.ini
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
  pip3 list --format=legacy | grep munch
}

install_munch () {
  pip3 install munch
}

install_node () {
  curl -sL https://rpm.nodesource.com/setup_14.x | bash -
  yum install -y nodejs
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
  HIVE_ODBC_INSTALLED=$(php -m | grep -E "^odbc")
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
  DREMIO_ODBC_INSTALLED=$(php -m | grep -E "^odbc")
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
  DATABRICKS_ODBC_INSTALLED = $(php -m | grep -E "^odbc")
}

install_hana_odbc () {
  # TODO: Implement SAP HANA ODBC driver installation for CentOS/RHEL
  echo_with_color red "\nSAP HANA ODBC driver installation is not yet implemented for CentOS/RHEL." >&5
  kill $!
  exit 1
}

enable_opcache () {
  {
    echo 'zend_extension=opcache.so'
    echo 'opcache.enable=1'
    echo 'opcache.memory_consumption=192'
    echo 'opcache.interned_strings_buffer=16'
    echo 'opcache.max_accelerated_files=16229;'
    echo 'opcache.max_wasted_percentage=15'
    echo 'opcache.validate_timestamps=0'
  } > /etc/php.d/10-opcache.ini
}

install_composer () {
  curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
  php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
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

  service mariadb start
  if (($? >= 1)); then
    echo_with_color red "\nCould not start MariaDB.. Exit " >&5
    kill $!
    exit 1
  fi
  systemctl enable mariadb
  mysqladmin -u root -h localhost password "${DB_PASS}"
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
      sudo -u "$CURRENT_USER" COMPOSER_ALLOW_SUPERUSER=1 bash -c "/usr/local/bin/composer install --no-dev"
    else
      sudo -u "$CURRENT_USER" bash -c "/usr/local/bin/composer install --no-dev"
    fi
  else
    if [[ $CURRENT_USER == "root" ]]; then
      sudo -u "$CURRENT_USER" COMPOSER_ALLOW_SUPERUSER=1 bash -c "/usr/local/bin/composer install --no-dev --ignore-platform-reqs"
    else
      sudo -u "$CURRENT_USER" bash -c "/usr/local/bin/composer install --no-dev --ignore-platform-reqs"
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



