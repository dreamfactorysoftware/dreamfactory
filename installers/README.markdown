# DreamFactory installation scripts.

This directory contains automated installer scripts for the following operating systems:

* CentOS / RHEL 7/8 (8 is currently in Beta)
* Debian 9/10
* Fedora 32/33
* Ubuntu 18/20

### Installation Requirements

For this wizard to work properly several conditions must be met:

* The wizard will be run on a fresh operating system installation. If you use these installers in conjunction with an existing Linux environment, the installer may skip some installation steps and you may need to manually perform additional configuration.
* DreamFactory will be the only web application running on this server. If you intend to run other sites using virtual hosts you will need to adjust the configuration to suit this requirement.
* The executing user must be able to use sudo(su) to run the installer.
* You'll need to make the script executable by changing its permissions (`sudo chmod +x ubuntu.sh`)/(`su -c "chmod +x debian.sh"`)
* If you want to use MySQL, PostgreSQL, or MS SQL Server for the system database, you'll be prompted to provide an **existing** database name, database username, and database password. DreamFactory cannot automatically create the database and user because it lacks administrative access to your database. Therefore before running the installer, create a database (you can name it anything), and then create a user with privileges allowing for the creation and modification of tables, as well as the usual CRUD (create, retrieve, update, delete) operations.

## Installation Options

You may pass several options into the script to alter its behavior. If you do not use these options, the script will install the Nginx web server, DreamFactory, and the required system and PHP extensions, but will **not install a database server**. During the script's execution you have the option to choose the SQLite database for your DreamFactory system database, which does not require any additional installation or configuration steps.

### Displaying the Help Menu

Passing the `--help` or `-h` option will present a list of all available installer options:

    $ sudo ./ubuntu.sh -h
    $ su -c "./debian.sh --help"

### Installing MySQL

Passing the `--with-mysql` option will result in installation of the MariaDB database. It will be used to house the system database. You can pass the option like this:

    $ sudo ./ubuntu.sh --with-mysql

If you do not provide this option then the script assumes you've already installed a database server and have root access to it. You'll be prompted to choose one of the following supported system databases:

* MySQL
* Postgres
* SQLite
* MS SQL Server

### Enabling Oracle

Passing the `--with-oracle` option will result in installation of PHP's Oracle (oci8) extension. You will need to supply a Silver or Gold license files to enable this functionality. If you choose this option you'll be prompted to identify the location of the the Oracle instant client zip files by providing an absolute path. Due to licensing restrictions we are unable to include these files with the installer, however you can download these files from [here](https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html). You can pass the option like this:

    $ sudo ./ubuntu.sh --with-oracle
    $ su -c "./debian.sh --with-oracle"

After navigating to the Oracle website you'll want to download the basic and sdk instant client files:

* instantclient-basic-linux.x64-19.12.0.0.0dbru.zip
* instantclient-sdk-linux.x64-19.12.0.0.0dbru.zip

For RPM based systems you'll want to download next files:

* oracle-instantclient19.12-basic-19.12.0.0.0-1.x86_64.rpm
* oracle-instantclient19.12-devel-19.12.0.0.0-1.x86_64.rpm

You should not unzip these files. Just upload them to your server and write down the absolute path to their location as you'll need to supply this path during the installation process.

The script only supports the Oracle driver version 19.12.

### Enabling IBM DB2

Passing the `--with-db2` option will result in installation of PHP's IBM DB2 (ibm_db2/pdo_ibm) extension.
Due to licensing restrictions we are unable to include these files with the installer, however you can download these files from [here](https://www.ibm.com/support/pages/download-initial-version-115-clients-and-drivers). This download requires you to register for a free account with IBM. You can pass the option like this:

    $ sudo ./ubuntu.sh --with-db2
    $ su -c "./debian.sh --with-db2"

After navigating to the IBM website you'll want to download the "IBM Data Server Driver Package (Linux AMD64 and Intel EM64T)" file:

* ibm_data_server_driver_package_linuxx64_v11.5.tar.gz

You should not unzip these files. Just upload them to your server and write down the absolute path to their location as you'll need to supply this path during the installation process.

### Enabling Cassandra

Passing the `--with-cassandra` option will result in installation of PHP's Cassandra extension. You can pass the option like this:

    $ sudo ./ubuntu.sh --with-cassandra
    $ su -c "./debian.sh --with-cassandra"

### Installing Apache

Passing the `--with-apache` option will result in the Apache 2 web server being installed instead of the default Nginx web server. You can pass the option like this:

    $ sudo ./ubuntu.sh --with-apache
    $ su -c "./debian.sh --with-apache"

### Installing Specific DreamFactory Version

Passing the `--with-tag=<version tag>` option will install a specific version of DreamFactory. If not specified, the latest available version of DreamFactory will be installed. You can pass the tag like this:

    $ sudo ./ubuntu,sh --with-tag=4.2.0
    $ su -c "./ubuntu,sh --with-tag=4.2.0"

### Supplying Multiple Options

You can supply multiple options to the installer like so:

    $ sudo ./ubuntu.sh --with-apache --with-oracle --with-mysql --with-cassandra --with-db2
    $ su -c "./debian.sh --with-apache --with-oracle --with-mysql --with-cassandra --with-db2"

### Installing a Commercial Version

These installers support both OSS and commercial DreamFactory versions. As part of the installation process you'll be asked if you'd like to upgrade the instance using our commercial Composer files:

    Would you like to upgrade your instance? [Yy/Nn]

If you choose yes (`Y` or `y`), you'll be prompted to enter the location of your commercial license files:

    Enter path to license files: [./]
    /home/ubuntu/

It is important that all three license files reside in the designated directory, including `composer.json`, `composer.lock`, and `composer.json-dist`. If any of the three are missing, the installer will ignore the upgrade step and continue.

When upgrading you'll also need to provide your license key:

    Please provide your license key:

Neglecting to provide this key will cause the upgrade process to fail, so please have it on hand before starting the installer. If you've misplaced the key, contact support for assistance.

### Accessing Your DreamFactory Installation

After finishing the installation process you can access to DreamFactory by typing your IP address or localhost in the browser. You should be directed to the login page of the admin application.

## Troubleshooting

If you get an error at some stage of the installation, fix it and run the script again. The script shows the installation steps to understand at what stage you have a problem.
For more detailed information about the installation process and errors, you can use a `--debug` key. The script will save all detailed information in a log file. The log file can be found in **tmp** directory. Full path: **/tmp/dreamfactory_installer.log**

    $ sudo ./ubuntu.sh --debug
    $ su -c "./debian.sh --debug"
