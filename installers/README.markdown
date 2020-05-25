# DreamFactory installation scripts.

This is a DreamFactory installation wizard for next OS:

* Ubuntu 16/18
* Debian 8/9

The scripts for CentOS and RHEL OS below version 7.5 not tested but the scripts have to work well too.  

### Installation Requirements

For this wizard to work properly several conditions must be met:

* The wizard will be run on a fresh Ubuntu or Debian installation. If you have existing resources installed on the server the script will skip some installation steps and you may need to manually perform additional configuration steps.
* DreamFactory will be the only web app running on this server. If you intend to run other sites using virtual hosts you will need to adjust the configuration to suit this requirement.
*  Only for Ubuntu OS: If the server has already installed PHP version 7.1, the script will install all extensions for DreamFactory compatible with that version PHP. Otherwise PHP 7.2 will be installed. **For other OS from list the script will install PHP 7.2.** DreamFactory 2.13.+ no longer supports PHP 7.0.
* The executing user must be able to use sudo(su) to run the installer.
* You'll need to make the script executable by changing its permissions (`sudo chmod +x ubuntu.sh`)/(`su -c "chmod +x debian.sh"`)

## Installation Options

You may pass several options into the script to alter its behavior. If you do not use these options, the script will install the Nginx web server, DreamFactory, and the required system and PHP extensions, but will **not install a database server**. During the script's execution you have the option to choose the SQLite database for your DreamFactory system database, which does not require any additional installation or configuration steps.

### Installing MySQL

Passing the ```--with-mysql``` option will result in installation of the MariaDB database. It will be used to house the system database. You can pass the option like this:

    $ sudo ./ubuntu.sh --with-mysql

If you do not provide this option then the script assumes you've already installed a database server and have root access to it. You'll be prompted to choose one of the following supported system databases:

* MySQL
* PostgreSQL
* SQLite
* MS SQL Server

In the case of MySQL, PostgreSQL, and MS SQL Server you'll be prompted to provide an **existing** database name, database username, and database password.

### Enabling Oracle

Passing the ```--with-oracle``` option will result in installation of PHP's Oracle (oci8) extension. You will need to supply a Silver or Gold license files to enable this functionality. If you choose this option you'll be prompted to identify the location of the the Oracle instant client zip files by providing an absolute path. Due to licensing restrictions we are unable to include these files with the installer, however you can download these files from [here](https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html). You can pass the option like this:

    $ sudo ./ubuntu.sh --with-oracle
    $ su -c "./debian.sh --with-oracle"

After navigating to the Oracle website you'll want to download the basic and sdk instant client files:

* instantclient-basic-linux.x64-18.5.0.0.0dbru.zip
* instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip

For RPM based systems you'll want to download next files:

* oracle-instantclient18.5-basic-18.5.0.0.0-3.x86_64.rpm
* oracle-instantclient18.5-devel-18.5.0.0.0-3.x86_64.rpm

You should not unzip these files. Just upload them to your server and write down the absolute path to their location as you'll need to supply this path during the installation process.

The script only supports the latest version of Oracle drivers (18.5).

### Enabling IBM DB2

Passing the ```--with-db2``` option will result in installation of PHP's IBM DB2 (ibm_db2/pdo_ibm) extension.
Due to licensing restrictions we are unable to include these files with the installer, however you can download these files from [here](https://www-01.ibm.com/marketing/iwm/iwm/web/preLogin.do?source=swg-idsdpds). This download requires you to register for a free account with IBM. You can pass the option like this:

    $ sudo ./ubuntu.sh --with-db2
    $ su -c "./debian.sh --with-db2"

After navigating to the IBM website you'll want to download the "IBM Data Server Driver Package (Linux AMD64 and Intel EM64T)" file:

* ibm_data_server_driver_package_linuxx64_v11.1.tar.gz

You should not unzip these files. Just upload them to your server and write down the absolute path to their location as you'll need to supply this path during the installation process.

### Enabling Cassandra

Passing the ```--with-cassandra``` option will result in installation of PHP's Cassandra extension. You can pass the option like this:

    $ sudo ./ubuntu.sh --with-cassandra
    $ su -c "./debian.sh --with-cassandra"

### Installing Apache

Passing the ```--with-apache``` option will result in the Apache 2 web server being installed instead of the default Nginx web server. You can pass the option like this:

    $ sudo ./ubuntu.sh --with-apache
    $ su -c "./debian.sh --with-apache"
    
### Installing specific DreamFactory version

Passing the ```--with-tag=<version tag>``` option will result in installation of DreamFactory. 
If not specified, the latest available version of DreamFactory will be installed. You can pass the option like this:

    $ sudo ./ubuntu,sh --with-tag=4.2.0
    $ su -c "./ubuntu,sh --with-tag=4.2.0"

### Supplying Multiple Options

You can supply multiple options to the installer like so:

    $ sudo ./ubuntu.sh --with-apache --with-oracle --with-mysql --with-cassandra --with-db2
    $ su -c "./debian.sh --with-apache --with-oracle --with-mysql --with-cassandra --with-db2"

### Upgrading Your Instance

As part of the installation process you'll be asked if you'd like to upgrade the instance using our commercial Composer files:

    Would you like to upgrade your instance? [Yy/Nn]

If you choose yes (`Y` or `y`), you'll be prompted to enter the location of your commercial license files:

    Enter path to license files: [./]
    /home/ubuntu/

It is important that all three license files reside in the designated directory, including `composer.json`, `composer.lock`, and `composer.json-dist`. If any of the three are missing, the installer will ignore the upgrade step and continue.

When upgrading you'll also need to provide your license key:

    Please provide your license key:

Neglecting to provide this key will cause the upgrade process to fail, so please have it on hand before starting the installer. If you've misplaced the key, contact support for assistance.

### Show help menu

Passing the ```--help```,```-h``` option will result in a show to you help menu with all available key for the script.

    $ sudo ./ubuntu.sh -h
    $ su -c "./debian.sh --help"

### Accessing Your DreamFactory Installation

After finishing the installation process you can access to DreamFactory by typing your IP address or localhost in the browser. You should be directed to the login page of the admin application.

## Troubleshooting

If you get an error at some stage of the installation, fix it and run the script again. The script shows the installation steps to understand at what stage you have a problem.
For more detailed information about the installation process and errors, you can use a ```--debug``` key. The script will save all detailed information in a log file. The log file can be found in **tmp** directory. Full path: **/tmp/dreamfactory_installer.log**

    $ sudo ./ubuntu.sh --debug
    $ su -c "./debian.sh --debug"

