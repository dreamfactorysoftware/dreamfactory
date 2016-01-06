## DreamFactory 2.0.4

[![License](https://poser.pugx.org/dreamfactory/dreamfactory/license.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/dreamfactorysoftware/dreamfactory?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Overview

DreamFactory(™) is an open source REST API backend for mobile, web, and IoT applications. 
It is built on top of the Laravel framework, and as such retains the requirements of the [Laravel v5.1 framework]

* Get powerful, reusable, documented APIs for SQL, NoSQL, files, email, push notifications and more. In seconds.
* Use server-side scripts to easily customize API behavior at any endpoint, for both API requests and API responses.
* Secure every API endpoint with user management, SSO authentication, role-based access control, OAuth and Active Directory integration.

Learn more at our [website](https://www.dreamfactory.com).

## Documentation

Documentation for the platform can be found on the [DreamFactory wiki](http://wiki.dreamfactory.com).

## Required software and extensions

Check our [wiki installation page](http://wiki.dreamfactory.com/DreamFactory/Installation) for the minimum 
software and extensions required for your system to successfully install and run DreamFactory 2.0.

## Quick Setup

These instructions allow you to quickly install DreamFactory 2.0 on your system and try it out. 
The commands shown here are primarily for a Linux based OS, 
but this should also work on Windows with all the required software and extensions installed.

> _Note: This quick setup instruction assumes that you are familiar with composer, git and the basics of how to setup a web and database server._


* Clone this repository to a directory on your system.
> git clone https://github.com/dreamfactorysoftware/dreamfactory.git ~/df2

* Change directory.
> cd ~/df2

* Install dependencies using composer.
> composer install --no-dev

* Run DreamFactory setup wizard. First time running this will create your system environment file (.env), 
generate application key, and will prompt you to configure your Database.
> php artisan dreamfactory:setup

* Run the above command again to complete the setup process. This time it will run the database schema migration, 
seed the default services, and will prompt you to create your admin user account.
> php artisan dreamfactory:setup

* Make sure your web server can read/write from/to storage/ (sub directories) and bootstrap/cache/ directories.
> Example:
>
> sudo chown -R {www user}:{your user group} storage/ bootstrap/cache/<br>
> sudo chmod -R 2775 storage/ bootstrap/cache/

* Run the following command to try out DreamFactory 2.0 without configuring a Database and Web Server. 
>php artisan serve


### Connecting to another Database Server after initial setup

To connect to a different Database Server after initial setup...

* Edit the .env file at the installation root and change the following configuration.
> DB_DRIVER=mysql     ## Supported drivers are sqlite (default), mysql, pgsql<br>
> DB_HOST=localhost<br>
> DB_DATABASE=dreamfactory<br>
> DB_USERNAME=username<br>
> DB_PASSWORD=secret<br>
> DB_PORT=3306

* Run following command to clear system cache.
> php artisan cache:clear

* Run DreamFactory setup wizard.
> php artisan dreamfactory:setup

* Make sure your web server can read/write from/to storage/ (sub directories) and bootstrap/cache/ directories.
> Example:
>
> sudo chown -R {www user}:{your user group} storage/ bootstrap/cache/<br>
> sudo chmod -R 2775 storage/ bootstrap/cache/

* Configure your web server to serve the public/ directory and launch your instance from a browser.


> _Note: The default composer.json has the more common package additions listed. To see all available packages, 
> see the composer.json-all-dist. Likewise to see the minimum required packages, see the composer.json-min-dist._

## Feedback and Contributions

* Feedback is welcome on our [forum](http://community.dreamfactory.com/) or in the form of pull requests and/or issues.
* Contributions should generally follow the strategy outlined in ["Contributing to a project"](http://help.github.com/articles/fork-a-repo#contributing-to-a-project)
* All pull requests must be in a ["git flow"](http://github.com/nvie/gitflow) feature branch to be considered.
