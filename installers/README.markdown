# DreamFactory installation scripts.

This directory contains an automated installer package `dfsetup.run` which will run on the following operating systems:

* CentOS 7
* RHEL 7/8
* Oracle Linux 7/8
* Debian 10/11
* Fedora 36/37
* Ubuntu 20/22

Simply run the installer with `sudo ./dfsetup.run`.

### Installation Requirements

For this wizard to work properly several conditions must be met:

* The wizard will be run on a fresh operating system installation. If you use these installers in conjunction with an existing Linux environment, the installer may skip some installation steps and you may need to manually perform additional configuration.
* DreamFactory will be the only web application running on this server. If you intend to run other sites using virtual hosts you will need to adjust the configuration to suit this requirement.
* The executing user must be able to use sudo(su) to run the installer.
* If you want to use MySQL, PostgreSQL, or MS SQL Server for the system database, you'll be prompted to provide an **existing** database name, database username, and database password. DreamFactory cannot automatically create the database and user because it lacks administrative access to your database. Therefore before running the installer, create a database (you can name it anything), and then create a user with privileges allowing for the creation and modification of tables, as well as the usual CRUD (create, retrieve, update, delete) operations.

## Installation Options

You will be greeted with a menu asking you if you would like to add any additional installation options (For example, Oracle db drivers, or using an Apache web server). You may choose as many as you wish by simply typing them in at the prompt (e.g `1,4` will install the necessary Oracle extensions and Apache). If you do not use these options, the script will install the Nginx web server, DreamFactory, and the required system and PHP extensions, but will **not install a database server**. During the script's execution you have the option to choose the SQLite database for your DreamFactory system database, which does not require any additional installation or configuration steps.

### Installing MySQL

Selecting option 5 at the prompt will result in installation of the MariaDB database. It will be used to house the system database. You can pass the option like this:

If you do not provide this option then the script assumes you've already installed a database server and have root access to it. You'll be prompted to choose one of the following supported system databases:

* MySQL
* Postgres
* SQLite
* MS SQL Server

### Enabling Oracle

Selecting option 1 at the initial menu prompt will result in installation of PHP's Oracle (oci8) extension. You will need to supply a Silver or Gold license files to enable this functionality. If you choose this option you'll be prompted to identify the location of the the Oracle instant client zip files by providing an absolute path. Due to licensing restrictions we are unable to include these files with the installer, however you can download these files from [here](https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html).

After navigating to the Oracle website you'll want to download the basic and sdk instant client files:

* instantclient-basic-linux.x64-21.9.0.0.0dbru.zip
* instantclient-sdk-linux.x64-21.9.0.0.0dbru.zip

For RPM based systems you'll want to download next files:

* oracle-instantclient-basic-21.9.0.0.0-1.el8.x86_64.rpm
* oracle-instantclient-devel-21.9.0.0.0-1.el8.x86_64.rpm

You should not unzip these files. Just upload them to your server and write down the absolute path to their location as you'll need to supply this path during the installation process.

The script was tested using Oracle driver versions 19.18 and 21.9.

### Enabling IBM DB2

Selecting option 2 at the initial menu prompt will result in installation of PHP's IBM DB2 (ibm_db2/pdo_ibm) extension.
Due to licensing restrictions we are unable to include these files with the installer, however you can download these files from [here](https://www.ibm.com/support/pages/download-initial-version-115-clients-and-drivers). This download requires you to register for a free account with IBM.

After navigating to the IBM website you'll want to download the "IBM Data Server Driver Package (Linux AMD64 and Intel EM64T)" file:

* ibm_data_server_driver_package_linuxx64_v11.5.tar.gz

You should not unzip these files. Just upload them to your server and write down the absolute path to their location as you'll need to supply this path during the installation process.

### Enabling Cassandra

Selecting option 3 at the initial menu prompt will result in installation of PHP's Cassandra extension.

### Installing Apache

Selecting option 4 at the initial menu prompt will result in the Apache 2 web server being installed instead of the default Nginx web server. Please note that if you opt for setting up Apache 2 as your default web server on Fedora, it might already be pre-installed. In such a scenario, the installation process for Apache 2 will be omitted.

### Installing Specific DreamFactory Version

Selecting option 6 at the initial menu prompt will install a specific version of DreamFactory. The installer will then ask you which version you would like to install. Please provide the version you wish to install (e.g. `4.9.0`) at the prompt. If this option is not selected, the latest available version of DreamFactory will be installed.

### Supplying Multiple Options

Supply multiple options at the menu prompt by comma separating the options you wish and press Enter (e.g. `1,4,5`).

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
For more detailed information about the installation process and errors, you can run the installer in debug mode using option 7 at the initial menu prompt. The script will save all detailed information in a log file. The log file can be found in **tmp** directory. Full path: **/tmp/dreamfactory_installer.log**

This installer was created using [Makeself](https://makeself.io/). The scripts within `dfsetup.run` can be seen in this directory's source folder.
