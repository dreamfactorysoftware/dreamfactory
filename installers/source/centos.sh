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
      wget
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

    yum-config-manager --enable remi-php74

    #Install PHP
    yum --enablerepo=remi-php74 install -y php-common \
      php-xml \
      php-cli \
      php-curl \
      php-json \
      php-mysqlnd \
      php-sqlite3 \
      php-soap \
      php-mbstring \
      php-bcmath \
      php-devel \
      php-ldap \
      php-pgsql \
      php-interbase \
      php-pdo-dblib \
      php-gd \
      php-zip
  else
    # RHEL 8
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-8.rpm

    dnf module list -y
    dnf module reset php -y
    dnf module enable php:remi-7.4 -y

    #Install PHP
    dnf install -y php-common \
      php-xml \
      php-cli \
      php-curl \
      php-json \
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
      php-zip
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
    yum --enablerepo=remi-php74 install -y php-fpm nginx
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
    yum --enablerepo=remi-php74 install -y php-pear
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
    yum --enablerepo=remi-php74 install -y libmcrypt-devel
  else
    dnf install -y libmcrypt-devel
  fi

  printf "\n" | pecl install mcrypt-1.0.4
  if (($? >= 1)); then
    echo_with_color red "\nMcrypt extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=mcrypt.so" >/etc/php.d/20-mcrypt.ini
}

install_mongodb () {
  pecl install mongodb
  if (($? >= 1)); then
    echo_with_color red "\nMongo DB extension installation error." >&5
    kill $!
    exit 1
  fi
  echo "extension=mongodb.so" >/etc/php.d/20-mongodb.ini
}

install_sql_server () {
  curl https://packages.microsoft.com/config/rhel/7/prod.repo >/etc/yum.repos.d/mssql-release.repo
  ACCEPT_EULA=Y yum install -y msodbcsql17 mssql-tools unixODBC-devel
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
    kill $!
    exit 1
  fi
}

install_pdo_sqlsrv () {
  ACCEPT_EULA=Y yum install -y php-sqlsrv php-pdo_sqlsrv
  if (($? >= 1)); then
    echo_with_color red "\nMS SQL Server extension installation error." >&5
    kill $!
    exit 1
  fi
}

install_oracle () {
  yum install -y libaio systemtap-sdt-devel $DRIVERS_PATH/oracle-instantclient19.*.rpm
  if (($? >= 1)); then
    echo_with_color red "\nOracle instant client installation error" >&5
    kill $!
    exit 1
  fi
  echo "/usr/lib/oracle/19.13/client64/lib" >/etc/ld.so.conf.d/oracle-instantclient.conf
  ldconfig
  export PHP_DTRACE=yes
  printf "\n" | pecl install oci8-2.2.0
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
  git clone https://github.com/dreamfactorysoftware/PDO_IBM-1.3.4-patched.git /opt/PDO_IBM-1.3.4-patched
  cd /opt/PDO_IBM-1.3.4-patched/ || exit 1
  sed -i 's/option_str = Z_STRVAL_PP(data);//' ibm_driver.c
  sed -i '985i\#if PHP_MAJOR_VERSION >= 7\' ibm_driver.c
  sed -i '986i\option_str = Z_STRVAL_P(data);\' ibm_driver.c
  sed -i '987i\#else\' ibm_driver.c
  sed -i '988i\option_str = Z_STRVAL_PP(data);\' ibm_driver.c
  sed -i '989i\#endif' ibm_driver.c
  phpize
  ./configure --with-pdo-ibm=/opt/dsdriver/lib
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
  yum install -y gmp-devel openssl-devel #boost cmake
  git clone https://github.com/datastax/php-driver.git /opt/cassandra
  cd /opt/cassandra/ || exit 1
  if ((CURRENT_OS == 7)); then
    wget http://downloads.datastax.com/cpp-driver/centos/7/cassandra/v2.10.0/cassandra-cpp-driver-2.10.0-1.el7.x86_64.rpm
    wget http://downloads.datastax.com/cpp-driver/centos/7/cassandra/v2.10.0/cassandra-cpp-driver-debuginfo-2.10.0-1.el7.x86_64.rpm
    wget http://downloads.datastax.com/cpp-driver/centos/7/cassandra/v2.10.0/cassandra-cpp-driver-devel-2.10.0-1.el7.x86_64.rpm
    wget http://downloads.datastax.com/cpp-driver/centos/7/dependencies/libuv/v1.23.0/libuv-1.23.0-1.el7.centos.x86_64.rpm
    wget http://downloads.datastax.com/cpp-driver/centos/7/dependencies/libuv/v1.23.0/libuv-debuginfo-1.23.0-1.el7.centos.x86_64.rpm
    wget http://downloads.datastax.com/cpp-driver/centos/7/dependencies/libuv/v1.23.0/libuv-devel-1.23.0-1.el7.centos.x86_64.rpm
  else
    wget https://downloads.datastax.com/cpp-driver/centos/8/cassandra/v2.16.0/cassandra-cpp-driver-2.16.0-1.el8.x86_64.rpm
    wget https://downloads.datastax.com/cpp-driver/centos/8/cassandra/v2.16.0/cassandra-cpp-driver-debuginfo-2.16.0-1.el8.x86_64.rpm
    wget https://downloads.datastax.com/cpp-driver/centos/8/cassandra/v2.16.0/cassandra-cpp-driver-devel-2.16.0-1.el8.x86_64.rpm
    wget https://downloads.datastax.com/cpp-driver/centos/8/dependencies/libuv/v1.35.0/libuv-1.35.0-1.el8.x86_64.rpm
    wget https://downloads.datastax.com/cpp-driver/centos/8/dependencies/libuv/v1.35.0/libuv-debuginfo-1.35.0-1.el8.x86_64.rpm
    wget https://downloads.datastax.com/cpp-driver/centos/8/dependencies/libuv/v1.35.0/libuv-devel-1.35.0-1.el8.x86_64.rpm
  fi
  yum install -y *.rpm
  if (($? >= 1)); then
    echo_with_color red "\ncassandra extension installation error." >&5
    kill $!
    exit 1
  fi
  ln -s /usr/lib64/libnsl.so.1 /usr/lib64/libnsl.so
  pecl install ./ext/package.xml
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

install_pcs () {
  pecl install pcs-1.3.7
  if (($? >= 1)); then
    echo_with_color red "\npcs extension installation error.." >&5
    kill $!
    exit 1
  fi
  echo "extension=pcs.so" >/etc/php.d/20-pcs.ini
}

install_snowflake () {
  yum update -y
  yum install -y gcc cmake php-pdo php-json php-devel
  # We need to use a previous version of the snowflake driver as the latest one seems to be bust.
  git clone -b v1.1.0 --single-branch https://github.com/snowflakedb/pdo_snowflake.git /src/snowflake
  cd /src/snowflake
  export PHP_HOME=/usr
  /src/snowflake/scripts/build_pdo_snowflake.sh
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

### INSTALL COUCHBASE
# We are in the process of upgrading this to SDK 3, therefor is currently not working and commented out
# php -m | grep -E "^couchbase"
# if (($? >= 1)); then
#   if ((CURRENT_OS == 7)); then
#     wget -P /tmp http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-4-x86_64.rpm
#     rpm -i /tmp/couchbase-release-1.0-4-x86_64.rpm
#     yum install -y libcouchbase-devel
#     pecl install couchbase-3.1.2
#   else
#     dnf update -y
#     wget -P /tmp http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-x86_64.rpm
#     rpm -i /tmp/couchbase-release-1.0-x86_64.rpm
#     dnf install -y libcouchbase-devel
#     pecl install couchbase 
#   fi

#   if (($? >= 1)); then
#     echo_with_color red "\ncouchbase extension installation error." >&5
#     exit 1
#   fi
#   echo "extension=couchbase.so" >/etc/php.d/xcouchbase.ini
#   php -m | grep couchbase
#   if (($? >= 1)); then
#     echo_with_color red "\nCould not install couchbase extension." >&5
#   fi
# fi
