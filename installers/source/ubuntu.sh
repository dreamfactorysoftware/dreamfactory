#!/bin/bash

### INSTALLER FUNCTIONS

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
    zip \
    unzip \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    lsof \
    libmcrypt-dev \
    libreadline-dev \
    wget \
    sudo

  # Check installation status
  if (($? >= 1)); then
    echo_with_color red "\n${ERROR_STRING}" >&5
    kill $!
    exit 1
  fi
}

install_php () {
  PHP_VERSION=$(php --version 2>/dev/null | head -n 1 | cut -d " " -f 2 | cut -c 1,3)
  CRYPT=0

  if [[ $PHP_VERSION =~ ^-?[0-9]+$ ]]; then
    if ((PHP_VERSION == 71)); then
      PHP_VERSION=php7.1
      MCRYPT=1
    else
      PHP_VERSION=${DEFAULT_PHP_VERSION}
    fi
  else
    PHP_VERSION=${DEFAULT_PHP_VERSION}
  fi

  PHP_VERSION_INDEX=$(echo $PHP_VERSION | cut -c 4-6)

  # Install the php repository
  add-apt-repository ppa:ondrej/php -y

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
    kill $!
    exit 1
  fi
}

check_apache_installation_status() {
  ps aux | grep -v grep | grep apache2
  CHECK_APACHE_PROCESS=$?

  dpkg -l | grep apache2 | cut -d " " -f 3 | grep -E "apache2$"
  CHECK_APACHE_INSTALLATION=$?
}

install_apache () {
  apt-get -qq install -y apache2 libapache2-mod-${PHP_VERSION}
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
#Default API call rate -> Here is set to 1 per second, and is later defined in the location /api/v2 section
limit_req_zone \$binary_remote_addr zone=mylimit:10m rate=1r/s;
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
    exit 1
  fi

  pecl channel-update pecl.php.net
}

install_mcrypt () {
  if [[ $MCRYPT == 0 ]]; then
    printf "\n" | pecl install mcrypt-1.0.4
    if (($? >= 1)); then
      echo_with_color red "\nMcrypt extension installation error." >&5
      kill $!
      exit 1
    fi
    echo "extension=mcrypt.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/mcrypt.ini"
    phpenmod -s ALL mcrypt
  else
    apt-get install ${PHP_VERSION}-mcrypt
  fi
}

install_mongodb () {
  pecl install mongodb
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
  if ((CURRENT_OS == 18)); then
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list >/etc/apt/sources.list.d/mssql-release.list
  else
    #ubuntu 20
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list >/etc/apt/sources.list.d/mssql-release.list
  fi
  apt-get update
  ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools unixodbc-dev
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
  pecl install pdo_sqlsrv
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
  echo "/opt/oracle/instantclient_19_13" >/etc/ld.so.conf.d/oracle-instantclient.conf
  printf "instantclient,/opt/oracle/instantclient_19_13\n" | pecl install oci8-2.2.0
  ldconfig
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
  git clone https://github.com/dreamfactorysoftware/PDO_IBM-1.3.4-patched.git /opt/PDO_IBM-1.3.4-patched
  cd /opt/PDO_IBM-1.3.4-patched/ || exit 1
  phpize
  ./configure --with-pdo-ibm=/opt/dsdriver/lib
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
  if ((CURRENT_OS == 20)); then
    # multiarch-support is unavailable in ubuntu20, we need to get it from the 18 archive
    wget http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/multiarch-support_2.27-3ubuntu1_amd64.deb
    apt install -y ./multiarch-support_2.27-3ubuntu1_amd64.deb
  fi
  apt install -y cmake libgmp-dev
  git clone https://github.com/datastax/php-driver.git /opt/cassandra
  cd /opt/cassandra/ || exit 1
  wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/cassandra/v2.10.0/cassandra-cpp-driver-dbg_2.10.0-1_amd64.deb
  wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/cassandra/v2.10.0/cassandra-cpp-driver-dev_2.10.0-1_amd64.deb
  wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/cassandra/v2.10.0/cassandra-cpp-driver_2.10.0-1_amd64.deb
  wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/dependencies/libuv/v1.23.0/libuv1-dbg_1.23.0-1_amd64.deb
  wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/dependencies/libuv/v1.23.0/libuv1-dev_1.23.0-1_amd64.deb
  wget http://downloads.datastax.com/cpp-driver/ubuntu/18.04/dependencies/libuv/v1.23.0/libuv1_1.23.0-1_amd64.deb
  dpkg -i *.deb
  if (($? >= 1)); then
    echo_with_color red "\ncassandra extension installation error." >&5
    kill $!
    exit 1
  fi
  pecl install ./ext/package.xml
  if (($? >= 1)); then
    echo_with_color red "\ncassandra extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=cassandra.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/cassandra.ini"
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
  if ((CURRENT_OS == 20)); then
    apt install -y python2
    # Pip2 is not supported on ubuntu anymore. We have to get a script from the python package
    # authority as below
    wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
    python2 get-pip.py
  else
    apt install -y python python-pip
  fi
}

check_bunch_installation () {
  if ((CURRENT_OS == 20)); then
    pip2 list | grep bunch
  else
    pip list | grep bunch
  fi  
}

install_bunch () {
  if ((CURRENT_OS == 20)); then
    pip2 install bunch
  else
    pip install bunch
  fi
}

install_python3 () {
  apt install -y python3 python3-pip
}

check_munch_installation () {
  python3 -m pip list | grep munch
}

install_munch () {
  python3 -m pip install munch
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

install_pcs () {
  pecl install pcs-1.3.7
  if (($? >= 1)); then
    echo_with_color red "\npcs extension installation error.." >&5
    kill $!
    exit 1
  fi
  echo "extension=pcs.so" >"/etc/php/${PHP_VERSION_INDEX}/mods-available/pcs.ini"
  phpenmod -s ALL pcs
}

install_snowflake_apache () {
  apt-get update
  apt-get install -y --no-install-recommends --allow-unauthenticated gcc cmake ${PHP_VERSION}-pdo ${PHP_VERSION}-json ${PHP_VERSION}-dev
  git clone https://github.com/snowflakedb/pdo_snowflake.git /src/snowflake
  cd /src/snowflake
  export PHP_HOME=/usr
  /src/snowflake/scripts/build_pdo_snowflake.sh
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
  /src/snowflake/scripts/build_pdo_snowflake.sh
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


add_mariadb_repo () {
  if ((CURRENT_OS == 18)); then
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
    add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main'
  else
    #ubuntu20
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
    add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu focal main'
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

### INSTALL COUCHBASE
# We are in the process of upgrading this to SDK 3, therefor is currently not working and commented out
# php -m | grep -E "^couchbase"
# if (($? >= 1)); then
#   if ((CURRENT_OS == 16)); then
#     wget -O - https://packages.couchbase.com/clients/c/repos/deb/couchbase.key | apt-key add -
#     echo "deb https://packages.couchbase.com/clients/c/repos/deb/ubuntu1604 xenial xenial/main" >/etc/apt/sources.list.d/couchbase.list
#   elif ((CURRENT_OS == 18)); then
#     wget -O - https://packages.couchbase.com/clients/c/repos/deb/couchbase.key | apt-key add -
#     echo "deb https://packages.couchbase.com/clients/c/repos/deb/ubuntu1804 bionic bionic/main" >/etc/apt/sources.list.d/couchbase.list
#   elif ((CURRENT_OS == 20)); then
#     wget -O - https://packages.couchbase.com/clients/c/repos/deb/couchbase.key | apt-key add -
#     echo "deb https://packages.couchbase.com/clients/c/repos/deb/ubuntu2004 focal focal/main" >/etc/apt/sources.list.d/couchbase.list
#   fi

#   apt-get update
#   apt install -y libcouchbase3 libcouchbase-dev libcouchbase3-tools libcouchbase-dbg libcouchbase3-libev libcouchbase3-libevent zlib1g-dev
#   pecl install couchbase
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
# fi
 