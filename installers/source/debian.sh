#!/bin/bash

### INSTALLER FUNCTIONS ###

# We will use these to run each step of the installer inside run_process which will provide us with a
# progress bar while things are going.

system_update () {
  apt-get update
}

install_system_dependencies () {
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
    sudo \
    jq

  # Check installation status
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi
}

install_php () {
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
    kill $!
    exit 1
  fi

  sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
  locale-gen
}

check_apache_installation_status () {
  ps aux | grep -v grep | grep apache2
  CHECK_APACHE_PROCESS=$?

  dpkg -l | grep apache2 | cut -d " " -f 3 | grep -E "apache2$"
  CHECK_APACHE_INSTALLATION=$?
}

install_apache () {
  apt-get install -y apache2 libapache2-mod-${PHP_VERSION}
  if (($? >= 1)); then
    echo_with_color red "\nCould not install Apache. Exiting." >&5
    kill $!
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
        <Files web.config>
          Require all denied
        </Files>
    </Directory>
</VirtualHost>" >/etc/apache2/sites-available/000-default.conf
}

restart_apache () {
  service apache2 restart
}

check_nginx_installation_status () {
  ps aux | grep -v grep | grep nginx
  CHECK_NGINX_PROCESS=$?

  dpkg -l | grep nginx | cut -d " " -f 3 | grep -E "nginx$"
  CHECK_NGINX_INSTALLATION=$?
}

install_nginx () {
  apt-get install -y nginx ${PHP_VERSION}-fpm
  if (($? >= 1)); then
    echo_with_color red "\nCould not install Nginx. Exiting." >&5
    kill $!
    exit 1
  fi
  # Change php fpm configuration file
  sed -i 's/\;cgi\.fix\_pathinfo\=1/cgi\.fix\_pathinfo\=0/' "$(php -i | sed -n '/^Loaded Configuration File => /{s:^.*> ::;p;}' | sed 's/cli/fpm/')"

  # Create nginx site entry
  echo "
# Default API call rate -> Here is set to 1 per second, and is later defined in the location /api/v2 section
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

    try_files  \$uri rewrite ^ /index.php?\$query_string;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/${PHP_VERSION}-fpm.sock;
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
}" >/etc/nginx/sites-available/default
}

restart_nginx () {
  service ${PHP_VERSION}-fpm restart && service nginx restart
}

install_php_pear () {
  apt-get install -y php-pear
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi

  pecl channel-update pecl.php.net
}

install_mcrypt () {
  printf "\n" | pecl install mcrypt-1.0.5
  if (($? >= 1)); then
    echo_with_color red "\nMcrypt extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=mcrypt.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/mcrypt.ini"
  phpenmod -s ALL mcrypt
}

install_mongodb () {
  pecl install mongodb <<<'no'
  if (($? >= 1)); then
    echo_with_color red "\nMongo DB extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=mongodb.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/mongodb.ini"
  phpenmod -s ALL mongodb
}

install_sql_server () {
  curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
  case $CURRENT_OS in

  10)
    curl https://packages.microsoft.com/config/debian/10/prod.list >/etc/apt/sources.list.d/mssql-release.list
    ;;
  11)
    curl https://packages.microsoft.com/config/debian/11/prod.list >/etc/apt/sources.list.d/mssql-release.list
    ;;
  esac
  apt-get update
  ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools unixodbc-dev=2.3.7 unixodbc=2.3.7 odbcinst1debian2=2.3.7 odbcinst=2.3.7

  pecl install sqlsrv
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=sqlsrv.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/sqlsrv.ini"
  phpenmod -s ALL sqlsrv
}

install_pdo_sqlsrv () {
  pecl install pdo_sqlsrv-5.10.1
  if (($? >= 1)); then
    echo_with_color red "\npdo_sqlsrv extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=pdo_sqlsrv.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/pdo_sqlsrv.ini"
  phpenmod -s ALL pdo_sqlsrv
}

install_oracle () {
  apt install -y libaio1
  CLIENT_VERSION=$(ls -f $DRIVERS_PATH/instantclient-basic-linux.x64-[12][19].*.0.0.0dbru.zip | grep -oP '([1-9]+)\.([1-9]+)' | head -n 1)
  CLIENT_VERSION=$(echo "$CLIENT_VERSION" | tr . _)
  echo "/opt/oracle/instantclient_$CLIENT_VERSION" >/etc/ld.so.conf.d/oracle-instantclient.conf
  ldconfig
  printf "instantclient,/opt/oracle/instantclient_$CLIENT_VERSION\n" | pecl install oci8-3.2.1
  if (($? >= 1)); then
    echo_with_color red "\nOracle instant client installation error" >&5
    kill $!
    exit 1
  fi
  echo "extension=oci8.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/oci8.ini"
  phpenmod -s ALL oci8
}

install_db2 () {
  apt install -y ksh
  chmod +x /opt/dsdriver/installDSDriver
  /usr/bin/ksh /opt/dsdriver/installDSDriver
  ln -s /opt/dsdriver/include /include
  git clone https://github.com/php/pecl-database-pdo_ibm.git /opt/pdo_ibm
  cd /opt/pdo_ibm || exit 1
  phpize
  ./configure --with-pdo-ibm=/opt/dsdriver
  make && make install
  if (($? >= 1)); then
    echo_with_color red "\nCould not make pdo_ibm extension." >&5
    kill $!
    exit 1
  fi
  echo "extension=pdo_ibm.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/pdo_ibm.ini"
  phpenmod -s ALL pdo_ibm
}

install_db2_extension () {
  printf "/opt/dsdriver/ \n" | pecl install ibm_db2
  if (($? >= 1)); then
    echo_with_color red "\nibm_db2 extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=ibm_db2.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/ibm_db2.ini"
  phpenmod -s ALL ibm_db2
}

install_cassandra () {
  apt-get install -y cmake libgmp-dev libpcre3-dev libssl-dev libuv1-dev libz-dev
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
  echo "extension=cassandra.so" | tee "/etc/php/${PHP_VERSION_INDEX}/mods-available/cassandra.ini" &&\
  phpenmod -s ALL cassandra
}

install_igbinary () {
  pecl install igbinary
  if (($? >= 1)); then
    echo_with_color red "\nigbinary extension installation error." >&5
    kill $!
    exit 1
  fi

  echo "extension=igbinary.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/igbinary.ini"
  phpenmod -s ALL igbinary
}

install_python2 () {
  if ((CURRENT_OS == 11)); then
    apt install python-is-python2 -y
    # Pip2 is not supported on ubuntu anymore. We have to get a script from the python package
    # authority as below
    wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
    python2 get-pip.py
  else
    apt install -y python python-pip
  fi
}

check_bunch_installation () {
  if ((CURRENT_OS == 11)); then
    pip2 list | grep bunch
  else
    pip list | grep bunch
  fi
}

install_bunch () {
  if ((CURRENT_OS == 11)); then
    pip2 install bunch
  else
    pip install bunch
  fi
}

install_python3 () {
  apt install -y python3 python3-pip
}

check_munch_installation () {
  pip3 list | grep munch
}

install_munch () {
  pip3 install munch
}

install_node () {
  curl -sL https://deb.nodesource.com/setup_14.x | bash -
  apt-get install -y nodejs
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi
  NODE_PATH=$(whereis node | cut -d" " -f2)
}

install_snowflake_apache () {
  apt-get update
  apt-get install -y --no-install-recommends --allow-unauthenticated gcc cmake ${PHP_VERSION}-pdo ${PHP_VERSION}-json ${PHP_VERSION}-dev
  git clone https://github.com/snowflakedb/pdo_snowflake.git /src/snowflake
  cd /src/snowflake
  export PHP_HOME=/usr
  # Execute script in the current shell, since the script does not see the PHP_HOME variable
  source /src/snowflake/scripts/build_pdo_snowflake.sh
  $PHP_HOME/bin/php -dextension=modules/pdo_snowflake.so -m | grep pdo_snowflake
  if (($? == 0)); then
    export PHP_HOME=/usr
    PHP_EXTENSION_DIR=$($PHP_HOME/bin/php -i | grep '^extension_dir' | sed 's/.*=>\(.*\).*/\1/')
    cp /src/snowflake/modules/pdo_snowflake.so $PHP_EXTENSION_DIR
    cp /src/snowflake/libsnowflakeclient/cacert.pem /etc/php/${PHP_VERSION_INDEX}/apache2/conf.d
    if (($? >= 1)); then
      echo_with_color red "\npdo_snowflake driver installation error." >&5
      kill $!
      exit 1
    fi
    echo -e "extension=pdo_snowflake.so\n\npdo_snowflake.cacert=/etc/php/${PHP_VERSION_INDEX}/apache2/conf.d/cacert.pem" >/etc/php/${PHP_VERSION_INDEX}/apache2/conf.d/20-pdo_snowflake.ini
  else
    echo_with_color red "\nCould not build pdo_snowflake driver." >&5
    kill $!
    exit 1
  fi
}

install_snowflake_nginx () {
  apt-get update
  apt-get install -y --no-install-recommends --allow-unauthenticated gcc cmake ${PHP_VERSION}-pdo ${PHP_VERSION}-json ${PHP_VERSION}-dev
  git clone https://github.com/snowflakedb/pdo_snowflake.git /src/snowflake
  cd /src/snowflake
  export PHP_HOME=/usr
  # Execute script in the current shell, since the script does not see the PHP_HOME variable
  source /src/snowflake/scripts/build_pdo_snowflake.sh
  $PHP_HOME/bin/php -dextension=modules/pdo_snowflake.so -m | grep pdo_snowflake
  if (($? == 0)); then
    export PHP_HOME=/usr
    PHP_EXTENSION_DIR=$($PHP_HOME/bin/php -i | grep '^extension_dir' | sed 's/.*=>\(.*\).*/\1/')
    cp /src/snowflake/modules/pdo_snowflake.so $PHP_EXTENSION_DIR
    cp /src/snowflake/libsnowflakeclient/cacert.pem /etc/php/${PHP_VERSION_INDEX}/fpm/conf.d
    if (($? >= 1)); then
      echo_with_color red "\npdo_snowflake driver installation error." >&5
      kill $!
      exit 1
    fi
    echo -e "extension=pdo_snowflake.so\n\npdo_snowflake.cacert=/etc/php/${PHP_VERSION_INDEX}/fpm/conf.d/cacert.pem" >/etc/php/${PHP_VERSION_INDEX}/fpm/conf.d/20-pdo_snowflake.ini
  else
    echo_with_color red "\nCould not build pdo_snowflake driver." >&5
    kill $!
    exit 1
  fi
}

install_hive_odbc () {
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
}

install_dremio_odbc () {
  apt-get update
  apt-get install -y --no-install-recommends --allow-unauthenticated ${PHP_VERSION}-odbc alien
  mkdir /opt/dremio
  cd /opt/dremio
  curl --fail -O https://download.dremio.com/arrow-flight-sql-odbc-driver/arrow-flight-sql-odbc-driver-LATEST.x86_64.rpm
  RPM_FILE=$(ls arrow-flight-sql-odbc-driver-*.rpm)
  alien --to-deb "$RPM_FILE"
  DEB_FILE=$(ls arrow-flight-sql-odbc-driver*.deb)
  dpkg -i "$DEB_FILE"
  rm -f "$RPM_FILE"
  rm -f "$DEB_FILE"
  test -f /opt/arrow-flight-sql-odbc-driver/lib64/libarrow-odbc.so.0.9.1.168
  export DREMIO_SERVER_ODBC_DRIVER_PATH=/opt/arrow-flight-sql-odbc-driver/lib64//libarrow-odbc.so.0.9.1.168
  DREMIO_ODBC_INSTALLED=$(php -m | grep -E "^odbc")
}

install_databricks_odbc () {
  apt-get update
  apt-get install -y --no-install-recommends --allow-unauthenticated ${PHP_VERSION}-odbc
  mkdir /opt/databricks
  cd /opt/databricks
  curl --fail -O https://databricks-bi-artifacts.s3.us-east-2.amazonaws.com/simbaspark-drivers/odbc/2.8.2/SimbaSparkODBC-2.8.2.1013-Debian-64bit.zip
  unzip -q SimbaSparkODBC-2.8.2.1013-Debian-64bit.zip
  rm -f SimbaSparkODBC-2.8.2.1013-Debian-64bit.zip
  rm -rf docs/
  dpkg -i simbaspark_2.8.2.1013-2_amd64.deb
  test -f /opt/simba/spark/lib/64/libsparkodbc_sb64.so
  rm simbaspark_2.8.2.1013-2_amd64.deb
  export DATABRICKS_SERVER_ODBC_DRIVER_PATH=/opt/simba/spark/lib/64/libsparkodbc_sb64.so
  DATABRICKS_ODBC_INSTALLED = $(php -m | grep -E "^odbc")
}

install_hana_odbc () {
  # TODO: Implement SAP HANA ODBC driver installation for Debian
  echo_with_color red "\nSAP HANA ODBC driver installation is not yet implemented for Debian." >&5
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
    echo 'opcache.jit_buffer_size=64M'
    echo 'opcache.jit=tracing'
  } > /etc/php/${PHP_VERSION_INDEX}/mods-available/opcache.ini
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
  dpkg -l | grep mysql | cut -d " " -f 3 | grep -E "^mysql" | grep -E -v "^mysql-client" | grep -v "mysql-common"
  CHECK_MYSQL_INSTALLATION=$?

  ps aux | grep -v grep | grep -E "^mysql"
  CHECK_MYSQL_PROCESS=$?

  lsof -i :3306 | grep LISTEN
  CHECK_MYSQL_PORT=$?
}

add_mariadb_repo () {
  if ((CURRENT_OS == 10)); then
    apt-key adv --no-tty --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.6/debian buster main'
  elif ((CURRENT_OS == 11)); then
    apt-key adv --no-tty --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.6/debian bullseye main'
  fi
}

install_mariadb () {
  apt-get install -y mariadb-server

  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi

  service mariadb start
  if (($? >= 1)); then
    service mysql start
    if (($? >= 1)); then
      echo_with_color red "\nCould not start MariaDB.. Exit " >&5
      kill $!
      exit 1
    fi
  fi
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

run_commercial_upgrade () {
  echo_with_color magenta "\nEnter absolute path to license files, complete with trailing slash: [/]" >&5
  read -r LICENSE_PATH

  if [[ -z $LICENSE_PATH ]]; then
    LICENSE_PATH="."
  fi

  ls $LICENSE_PATH/composer.{json,lock,json-dist}

  if (($? >= 1)); then
    echo_with_color red "\nLicenses not found. Exiting!\n" >&5
    kill $!
    exit 1
  fi

  cp $LICENSE_PATH/composer.{json,lock,json-dist} /opt/dreamfactory/
  echo_with_color green "\nLicense files installed. \n" >&5
  echo_with_color green "Upgrading DreamFactory to %s...\n" "$latest_tag" >&5
}

run_open_source_upgrade () {
  # pull the latest tag from the repo
  git pull origin "$latest_tag"
}

run_artisan_commands () {
  bash -c "php artisan migrate --seed"
  bash -c "php artisan optimize:clear"
}

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
  # read the app.php file in the config folder and get the version
  current_version=$(grep -Eo 'version.*[0-9]+\.[0-9]+\.[0-9]+' config/app.php | cut -d "'" -f 3)

  # Check if the current version is less then 5.0.0
  if dpkg --compare-versions "$current_version" lt-nl "5.0.0"; then
    echo_with_color red "DreamFactory version is less than 5.0.0. Please upgrade to v5 first or contact DreamFactory support." >&5
    kill $!
    exit 1
  fi

  # Compare the current version with the latest tag
  if dpkg --compare-versions "$current_version" eq "$latest_tag"; then
    echo_with_color red "DreamFactory is already up to date." >&5
    kill $!
    exit 1
  fi

  # Check if the current version is greater than the latest tag (this should not happen but we check anyway)
  if dpkg --compare-versions "$current_version" gt "$latest_tag"; then
    echo_with_color red "Installed DreamFactory version is greater than the published version. Please contact DreamFactory support." >&5
    kill $!
    exit 1
  fi

  # Check if there are uncommitted changes and ignore the public folder
  if ! git diff --quiet HEAD -- "$DESTINATION_FOLDER"; then
      echo_with_color red "There are uncommitted changes in the repository. Please clean the installation folder before upgrading." >&5
      kill $!
      exit 1
  fi

  #  Ask if the DF instance is commercial or not
  echo_with_color magenta "Is this a commercial DreamFactory instance? [Yy/Nn]\n" >&5
  read -r LICENSE_FILE_ANSWER

  if [[ -z $LICENSE_FILE_ANSWER ]]; then
    LICENSE_FILE_ANSWER=N
  fi

  if [[ $LICENSE_FILE_ANSWER =~ ^[Yy]$ ]]; then
    echo_with_color blue "  Upgrading commercial version\n" >&5
    run_commercial_upgrade
  else
    echo_with_color blue "  Upgrading open source version\n" >&5
    run_open_source_upgrade
  fi

  # install the composer files
  echo_with_color blue "   Updating DreamFactory\n" >&5
  run_composer_install

  # Call artisan commands
  echo_with_color blue "   Running artisan commands\n" >&5
  run_artisan_commands

  # Change ownership to current user
  chown -R $owner:$group /opt/dreamfactory
}