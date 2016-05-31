#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

# Change OUTPUT to /dev/stdout to see shell output while provisioning.
OUTPUT=/dev/null

echo ">>> Updating apt-get"
sudo apt-get -qq update

echo ">>> Installing php ldap extension"
sudo apt-get install -qq -y php-ldap > $OUTPUT 2>&1

#echo ">>> Installing php mssql extension"
#sudo apt-get install -qq -y php5-mssql > $OUTPUT 2>&1

echo ">>> Installing mongodb driver"
sudo apt-get install -qq -y autoconf g++ make openssl libssl-dev libcurl4-openssl-dev > $OUTPUT 2>&1
sudo apt-get install -qq -y libcurl4-openssl-dev pkg-config > $OUTPUT 2>&1
sudo apt-get install -qq -y libsasl2-dev > $OUTPUT 2>&1
sudo pecl install mongodb > $OUTPUT 2>&1
sudo echo "extension=mongodb.so" > /etc/php/7.0/mods-available/mongodb.ini
sudo ln -s /etc/php/7.0/mods-available/mongodb.ini /etc/php/7.0/cli/conf.d/99-mongodb.ini
sudo ln -s /etc/php/7.0/mods-available/mongodb.ini /etc/php/7.0/fpm/conf.d/99-mongodb.ini

#echo ">>> Installing v8js extension"
#sudo apt-get install -qq -y libv8-dev > $OUTPUT 2>&1
#sudo pecl install v8js-0.1.3 > $OUTPUT 2>&1
#sudo echo "extension=v8js.so" > /etc/php/7.0/mods-available/v8js.ini
#sudo ln -s /etc/php/7.0/mods-available/v8js.ini /etc/php/7.0/cli/conf.d/99-v8js.ini
#sudo ln -s /etc/php/7.0/mods-available/v8js.ini /etc/php/7.0/fpm/conf.d/99-v8js.ini
cd */.

echo ">>> Installing phpMyAdmin (http://host/pma)"
sudo apt-get install -qq -y phpmyadmin > $OUTPUT 2>&1
sudo ln -s /usr/share/phpmyadmin/ public/pma

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

echo ">>> Installing Node.js lodash"
sudo npm install lodash > $OUTPUT 2>&1

sudo service php5-fpm restart
sudo service nginx restart

echo ">>> Setup complete. Launch your instance."
