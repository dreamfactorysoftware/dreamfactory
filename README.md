## DreamFactory 2.14.0

[![License](https://poser.pugx.org/dreamfactory/dreamfactory/license.svg)](http://www.apache.org/licenses/LICENSE-2.0)

## Overview

DreamFactory(™) is an open source REST API backend for mobile, web, and IoT applications. 
It is built on top of the Laravel framework, and as such retains the requirements of the [Laravel v5.5 framework]

* Generate powerful, reusable, documented APIs for SQL, NoSQL, files, email, push notifications and more in seconds.
* Use server-side scripts to easily customize API behavior at any endpoint, for both API requests and API responses.
* Secure every API endpoint with user management, SSO authentication, role-based access control, OAuth and Active Directory integration.

Learn more at our [website](https://www.dreamfactory.com).

## Commercial Licenses

In need of official technical support? Desire access to REST API generators for SQL Server, Oracle, SOAP, or mobile
push notifications? Require API limiting and/or auditing? Schedule a demo [with our team](https://www.dreamfactory.com/contact)!

## Documentation

Documentation for the platform can be found on the [DreamFactory wiki](http://wiki.dreamfactory.com).

## Required Software and Extensions

Check our [wiki installation page](http://wiki.dreamfactory.com/DreamFactory/Installation) for the minimum 
software and extensions required for your system to successfully install and run DreamFactory 2.x.

## Quick Setup

These instructions allow you to quickly install DreamFactory 2.x on your system and try it out. 
The commands shown here are primarily for a Linux based OS, 
but this should also work on Windows with all the required software and extensions installed.

> _Note: This quick setup instruction assumes that you are familiar with composer, git and the basics of how to setup a web and database server._


 * Clone this repository to a directory on your system.

    ```sh
    git clone https://github.com/dreamfactorysoftware/dreamfactory.git ~/df2
    ```

 * Change directory.

    ```sh
    cd ~/df2
    ```

 * Install dependencies using composer. If composer is not installed, see [here](https://getcomposer.org/download/).

    ```sh
    composer install --no-dev
    ```

 * DreamFactory sets up a default SQLite database by default. If you would like your instance to store system 
 information in another database, run the following command. This will create your system environment file (.env) 
 and will prompt you to configure your database of choice.

    ```sh
    php artisan df:env
    ```

 * Regardless of what database you choose, run the following command to setup your database. 
 This will create your system environment, generate your application key, run the database schema migration, 
 seed the default services, and will prompt you to create your admin user account.

    ```sh
    php artisan df:setup
    ```

 * Make sure your web server can read/write from/to storage/ (sub directories) and bootstrap/cache/ directories.

    ```sh
    # Example:
    
    sudo chown -R {www user}:{your user group} storage/ bootstrap/cache/
    sudo chmod -R 2775 storage/ bootstrap/cache/
    ```

 * Run the following command to try out DreamFactory 2.0 without configuring a web server. 
 Otherwise, configure your web server to serve the public/ directory and launch your instance from a browser.

    ```sh
    php artisan serve
    ```

### Customize the Installation

To customize any of the environment settings or feature sets included in the install, run the new installer program.

> _Note this requires Bash 4.0 or newer._

 * Run the installer and follow the prompts. If the installer can not be run, you may edit the .env file directly.

    ```sh
    ./installer.sh
    ```
    
 * Run following commands to clear system cache.

    ```sh
    php artisan cache:clear
    php artisan config:clear
    ```

 * If the system database environment is changed to a clean database, re-run the setup command.

    ```sh
    php artisan df:setup
    ```
    

## Feedback and Contributions

* Feedback is welcome on our [forum](http://community.dreamfactory.com/) or in the form of pull requests and/or issues.
* Contributions should generally follow the strategy outlined in ["Contributing to a project"](http://help.github.com/articles/fork-a-repo#contributing-to-a-project)
* All pull requests must be in a ["git flow"](http://github.com/nvie/gitflow) feature branch to be considered.
