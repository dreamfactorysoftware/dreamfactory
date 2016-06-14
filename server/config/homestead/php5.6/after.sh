#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

# This script is compatible with "laravel/homestead": "v2.2.1"

# Change OUTPUT to /dev/stdout to see shell output while provisioning.
OUTPUT=/dev/null

echo ">>> Updating apt-get"
sudo apt-get -qq update

echo ">>> Installing php ldap extension"
sudo apt-get install -qq -y php5-ldap > $OUTPUT 2>&1

echo ">>> Installing php mongodb extension"
sudo apt-get install -qq -y autoconf g++ make openssl libssl-dev libcurl4-openssl-dev > $OUTPUT 2>&1
sudo apt-get install -qq -y libcurl4-openssl-dev pkg-config > $OUTPUT 2>&1
sudo apt-get install -qq -y libsasl2-dev > $OUTPUT 2>&1
sudo pecl install mongodb > $OUTPUT 2>&1
sudo echo "extension=mongodb.so" > /etc/php5/mods-available/mongodb.ini
sudo php5enmod mongodb

echo ">>> Installing php v8js extension"
sudo apt-get install -qq -y libv8-dev > $OUTPUT 2>&1
sudo pecl install v8js-0.1.3 > $OUTPUT 2>&1
sudo echo "extension=v8js.so" > /etc/php5/mods-available/v8js.ini
sudo php5enmod v8js

echo ">>> Installing php mssql extension"
sudo apt-get install -qq -y php5-mssql > $OUTPUT 2>&1
cd */.
sudo mv /etc/freetds/freetds.conf /etc/freetds/freetds.conf.original
sudo cp server/config/freetds/sqlsrv.conf /etc/freetds/freetds.conf
sudo cp server/config/freetds/locales.conf /etc/freetds/locales.conf

echo ">>> Installing phpMyAdmin (http://<host>/pma)"
sudo apt-get install -qq -y phpmyadmin > $OUTPUT 2>&1
sudo ln -s /usr/share/phpmyadmin/ public/pma > $OUTPUT 2>&1

echo ">>> Setting up workbench/repos/df-admin-app with bower and grunt"
echo ">>> Installing bower"
sudo npm install -g bower > $OUTPUT 2>&1
echo ">>> Installing grunt-cli"
sudo npm install -g grunt-cli > $OUTPUT 2>&1
mkdir -p workbench/repos
cd workbench/repos
git clone https://github.com/dreamfactorysoftware/df-admin-app.git > $OUTPUT 2>&1
cd df-admin-app
git checkout develop > $OUTPUT 2>&1
cd ../../../public/dreamfactory
ln -s ../../workbench/repos/df-admin-app . > $OUTPUT 2>&1
cd ../../

echo ">>> Setting up dreamfactory .env with homestead mysql database"
sudo php artisan cache:clear
sudo php artisan config:clear
sudo php artisan clear-compiled
cp .env .env-backup-homestead
rm .env
php artisan dreamfactory:setup --db_driver=mysql --db_host=127.0.0.1 --db_database=homestead --db_username=homestead --db_password=secret --cache_driver=file > $OUTPUT 2>&1

cd ../
echo ">>> Installing 'zip' command"
sudo apt-get install -qq -y zip > $OUTPUT 2>&1

echo ">>> Installing Python bunch"
sudo pip install bunch > $OUTPUT 2>&1

echo ">>> Installing lodash"
sudo npm install lodash > $OUTPUT 2>&1

sudo service php5-fpm restart
sudo service nginx restart

echo ">>> Setup complete. Launch your instance."
