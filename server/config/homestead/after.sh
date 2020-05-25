#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

# This script is compatible with "laravel/homestead": "^3.0"

# Change OUTPUT to /dev/stdout to see shell output while provisioning.
OUTPUT=/dev/stdout

echo ">>> Switching php version to 7.1"
sudo update-alternatives --set php /usr/bin/php7.1

echo ">>> Beginning DreamFactory provisioning..."
sudo apt-get update -qq -y

echo ">>> Installing postfix for local email service"
echo "postfix postfix/mailname string mail.example.com" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix > $OUTPUT 2>&1

#echo ">>> Installing php ldap extension"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php7.1-ldap > $OUTPUT 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php7.0-ldap > $OUTPUT 2>&1
#sudo apt-get install -qq -y php5.6-ldap > $OUTPUT 2>&1

echo ">>> Installing php sybase extension"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php7.1-sybase > $OUTPUT 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php7.0-sybase > $OUTPUT 2>&1
#sudo apt-get install -qq -y php5.6-sybase > $OUTPUT 2>&1

echo ">>> Installing php interbase (firebird) extension"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y php7.1-interbase > $OUTPUT 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y php7.0-interbase > $OUTPUT 2>&1
#sudo apt-get install -qq -y php5.6-interbase > $OUTPUT 2>&1

echo ">>> Installing php mongodb extension"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y php7.1-mongodb > $OUTPUT 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y php7.0-mongodb > $OUTPUT 2>&1
#sudo apt-get install -qq -y php5.6-mongodb > $OUTPUT 2>&1

echo ">>> Installing php cassandra extension"
mkdir cassandra
cd cassandra
sudo apt-get install -qq -y libgmp-dev libpcre3-dev g++ make cmake libssl-dev openssl > $OUTPUT 2>&1
wget -q http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.11.0/libuv_1.11.0-1_amd64.deb
wget -q http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.11.0/libuv-dev_1.11.0-1_amd64.deb
wget -q http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.6.0/cassandra-cpp-driver_2.6.0-1_amd64.deb
wget -q http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.6.0/cassandra-cpp-driver-dev_2.6.0-1_amd64.deb
sudo dpkg -i libuv_1.11.0-1_amd64.deb > $OUTPUT 2>&1
sudo dpkg -i libuv-dev_1.11.0-1_amd64.deb> $OUTPUT 2>&1
sudo dpkg -i cassandra-cpp-driver_2.6.0-1_amd64.deb > $OUTPUT 2>&1
sudo dpkg -i cassandra-cpp-driver-dev_2.6.0-1_amd64.deb > $OUTPUT 2>&1
git clone https://github.com/datastax/php-driver.git > $OUTPUT 2>&1
cd php-driver
git checkout tags/v1.2.2 > $OUTPUT 2>&1
cd ext
phpize > $OUTPUT 2>&1
./configure > $OUTPUT 2>&1
make > $OUTPUT 2>&1
sudo make install > $OUTPUT 2>&1
sudo echo "extension=cassandra.so" > /etc/php/7.1/mods-available/cassandra.ini
sudo phpenmod cassandra > $OUTPUT 2>&1
cd ../../../
sudo rm -R cassandra

echo ">>> Installing php couchbase extension"
wget http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-3-amd64.deb > $OUTPUT 2>&1
sudo dpkg -i couchbase-release-1.0-3-amd64.deb > $OUTPUT 2>&1
sudo apt-get update > $OUTPUT 2>&1
sudo apt-get -y install libcouchbase-dev build-essential php-dev zlib1g-dev > $OUTPUT 2>&1
sudo pecl -d php_suffix=7.1 install couchbase > $OUTPUT 2>&1
sudo echo "extension=couchbase.so" > /etc/php/7.1/mods-available/xcouchbase.ini
sudo php -r 'file_put_contents("/etc/php/7.1/cli/php.ini", str_replace("extension=\"couchbase.so\"", "", file_get_contents("/etc/php/7.1/cli/php.ini")));' > $OUTPUT 2>&1
sudo phpdismod couchbase > $OUTPUT 2>&1
sudo phpenmod xcouchbase > $OUTPUT 2>&1

echo ">>> Installing phpMyAdmin (http://host/pma)"
cd */.
composer create-project phpmyadmin/phpmyadmin --repository-url=https://www.phpmyadmin.net/packages.json --no-dev public/pma > $OUTPUT 2>&1

echo ">>> Installing bower"
sudo npm install -g bower > $OUTPUT 2>&1
echo ">>> Installing grunt-cli"
sudo npm install -g grunt-cli > $OUTPUT 2>&1

echo ">>> Setting up workbench for all packages";
mkdir -p workbench/repos > $OUTPUT 2>&1
cd workbench/repos
echo ">>> ----> Cloning df-admin-app";
git clone -b develop https://github.com/dreamfactorysoftware/df-admin-app.git > $OUTPUT 2>&1
echo ">>> ----> Cloning df-api-docs-ui";
git clone -b develop https://github.com/dreamfactorysoftware/df-api-docs-ui.git > $OUTPUT 2>&1
echo ">>> ----> Cloning df-filemanager-app";
git clone -b develop https://github.com/dreamfactorysoftware/df-filemanager-app.git > $OUTPUT 2>&1
cd ../../public
ln -s ../workbench/repos/df-api-docs-ui dev-df-api-docs-ui > $OUTPUT 2>&1
ln -s ../workbench/repos/df-admin-app dev-df-admin-app > $OUTPUT 2>&1
ln -s ../workbench/repos/df-filemanager-app dev-df-filemanager-app > $OUTPUT 2>&1
cd ../

echo ">>> Installing workbench git tools"
cp server/config/homestead/tools/*.php workbench/repos/

echo ">>> Create database (df_unit_test) for unit test"
mysql -e "CREATE DATABASE IF NOT EXISTS \`df_unit_test\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";

echo ">>> Setting up dreamfactory .env with homestead mysql database"
sudo php artisan cache:clear
sudo php artisan config:clear
sudo php artisan clear-compiled
cp .env .env-backup-homestead > $OUTPUT 2>&1
rm .env > $OUTPUT 2>&1
php artisan df:env --db_connection=mysql --db_host=127.0.0.1 --db_database=homestead --db_username=homestead --db_password=secret > $OUTPUT 2>&1

cd ../
echo ">>> Installing 'zip' command"
sudo apt-get install -qq -y zip > $OUTPUT 2>&1

echo ">>> Installing Python bunch"
sudo pip install bunch > $OUTPUT 2>&1

echo ">>> Installing Python3 munch"
if command -v pip; then
  sudo pip3 install munch > $OUTPUT 2>&1
else
  sudo pip install munch > $OUTPUT 2>&1
fi

echo ">>> Installing Node.js lodash"
sudo npm install lodash > $OUTPUT 2>&1

echo ">>> Configuring XDebug"
printf "xdebug.remote_enable=1\nxdebug.remote_connect_back=1\nxdebug.max_nesting_level=512" | sudo tee -a /etc/php/7.0/mods-available/xdebug.ini > $OUTPUT 2>&1

echo ">>> Configuring NGINX to allow editing .php file using storage services."
sudo php -r 'file_put_contents("/etc/nginx/sites-available/homestead.localhost", str_replace("location ~ \.php$ {", "location ~ \.php$ {\n        try_files  "."$"."uri rewrite ^ /index.php?"."$"."query_string;", file_get_contents("/etc/nginx/sites-available/homestead.localhost")));'

sudo service php7.1-fpm restart
sudo service php7.0-fpm restart
sudo service php5.6-fpm restart
sudo service nginx restart

echo ">>> Provisioning complete. Launch your instance."
