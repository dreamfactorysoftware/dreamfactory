#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

# This script is compatible with "laravel/homestead": "^3.0"

# Change OUTPUT to /dev/stdout to see shell output while provisioning.
OUTPUT=/dev/null

echo ">>> Beginning DreamFactory provisioning..."
echo ">>> Updating apt-get"
sudo apt-get -qq update

echo ">>> Upgrading PHP 7.1 and dependencies"
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -y upgrade php7.1-fpm php7.1-cli php7.1-common php7.1-dev > $OUTPUT 2>&1

echo ">>> Installing php ldap extension"
sudo apt-get install -qq -y php7.1-ldap > $OUTPUT 2>&1

echo ">>> Installing php sybase extension"
sudo apt-get install -qq -y php7.1-sybase > $OUTPUT 2>&1

echo ">>> Installing php mongodb extension"
sudo apt-get install -qq -y openssl pkg-config > $OUTPUT 2>&1
sudo pecl install mongodb > $OUTPUT 2>&1
sudo echo "extension=mongodb.so" > /etc/php/7.1/mods-available/mongodb.ini
sudo phpenmod mongodb

#echo ">>> Compiling V8 and installing php v8js"
#sudo apt-get install -qq -y build-essential git python libglib2.0-dev > $OUTPUT 2>&1
#cd /tmp
#git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git > $OUTPUT 2>&1
#export PATH=`pwd`/depot_tools:"$PATH" > $OUTPUT 2>&1
#fetch v8 > $OUTPUT 2>&1
#cd v8
#git checkout 5.6.326.12 > $OUTPUT 2>&1
#gclient sync > $OUTPUT 2>&1
#tools/dev/v8gen.py -vv x64.release > $OUTPUT 2>&1
#echo is_component_build = true >> out.gn/x64.release/args.gn > $OUTPUT 2>&1
#ninja -C out.gn/x64.release/ > $OUTPUT 2>&1
#sudo mkdir -p /opt/v8/{lib,include} > $OUTPUT 2>&1
#sudo cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin /opt/v8/lib/ > $OUTPUT 2>&1
#sudo cp -R include/* /opt/v8/include/ > $OUTPUT 2>&1
#cd /tmp
#git clone https://github.com/phpv8/v8js.git > $OUTPUT 2>&1
#cd v8js
#phpize > $OUTPUT 2>&1
#./configure --with-v8js=/opt/v8 > $OUTPUT 2>&1
#make > $OUTPUT 2>&1
#sudo make install > $OUTPUT 2>&1
#sudo phpenmod v8js > $OUTPUT 2>&1
#cd /tmp

#git clone https://github.com/dreamfactorysoftware/df-docker.git > $OUTPUT 2>&1
#cd df-docker
#sudo mkdir -p /usr/lib /usr/include
#sudo cp -R v8/usr/lib/libv8* /usr/lib/
#sudo cp -R v8/usr/include /usr/include/
#sudo cp v8/usr/lib/php/20151012/v8js.so /usr/lib/php/20160303/v8js.so
#sudo echo "extension=v8js.so" > /etc/php/7.1/mods-available/v8js.ini
#sudo phpenmod v8js
#cd ../
#sudo rm -R df-docker

echo ">>> Installing php cassandra extension"
mkdir cassandra
cd cassandra
sudo apt-get install -qq -y libgmp-dev libpcre3-dev g++ make cmake libssl-dev openssl > $OUTPUT 2>&1
wget -q http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependenices/libuv/v1.8.0/libuv_1.8.0-1_amd64.deb
wget -q http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependenices/libuv/v1.8.0/libuv-dev_1.8.0-1_amd64.deb
wget -q http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.4.2/cassandra-cpp-driver_2.4.2-1_amd64.deb
wget -q http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.4.2/cassandra-cpp-driver-dev_2.4.2-1_amd64.deb
sudo dpkg -i libuv_1.8.0-1_amd64.deb > $OUTPUT 2>&1
sudo dpkg -i libuv-dev_1.8.0-1_amd64.deb > $OUTPUT 2>&1
sudo dpkg -i cassandra-cpp-driver_2.4.2-1_amd64.deb > $OUTPUT 2>&1
sudo dpkg -i cassandra-cpp-driver-dev_2.4.2-1_amd64.deb > $OUTPUT 2>&1
git clone https://github.com/datastax/php-driver.git > $OUTPUT 2>&1
cd php-driver/ext
phpize > $OUTPUT 2>&1
./configure > $OUTPUT 2>&1
make > $OUTPUT 2>&1
sudo make install > $OUTPUT 2>&1
sudo echo "extension=cassandra.so" > /etc/php/7.1/mods-available/cassandra.ini
sudo phpenmod cassandra
cd ../../../
sudo rm -R cassandra

echo ">>> Installing phpMyAdmin (http://host/pma)"
cd */.
composer create-project phpmyadmin/phpmyadmin --repository-url=https://www.phpmyadmin.net/packages.json --no-dev public/pma > $OUTPUT 2>&1

echo ">>> Setting up workbench/repos/df-admin-app with bower and grunt"
echo ">>> Installing bower"
sudo npm install -g bower > $OUTPUT 2>&1
echo ">>> Installing grunt-cli"
sudo npm install -g grunt-cli > $OUTPUT 2>&1
mkdir -p workbench/repos > $OUTPUT 2>&1
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
cp .env .env-backup-homestead > $OUTPUT 2>&1
rm .env > $OUTPUT 2>&1
php artisan dreamfactory:setup --db_driver=mysql --db_host=127.0.0.1 --db_database=homestead --db_username=homestead --db_password=secret --cache_driver=file > $OUTPUT 2>&1

cd ../
echo ">>> Installing 'zip' command"
sudo apt-get install -qq -y zip > $OUTPUT 2>&1

echo ">>> Installing Python bunch"
sudo pip install bunch > $OUTPUT 2>&1

echo ">>> Installing Node.js lodash"
sudo npm install lodash > $OUTPUT 2>&1

echo ">>> Configuring XDebug"
printf "xdebug.remote_enable=1\nxdebug.remote_connect_back=1\nxdebug.max_nesting_level=512" | sudo tee -a /etc/php/7.0/mods-available/xdebug.ini > $OUTPUT 2>&1

sudo service php7.1-fpm restart
sudo service nginx restart

echo ">>> Provisioning complete. Launch your instance."
