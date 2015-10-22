## DreamFactory 2.0

DreamFactory is an open source REST API backend for mobile, web, and IoT applications.

* Get powerful, reusable, documented APIs for SQL, NoSQL, files, email, push notifications and more. In seconds.
* Use server-side scripts to easily customize API behavior at any endpoint, for both API requests and API responses.
* Secure every API endpoint with user management, SSO authentication, role-based access control, OAuth and Active Directory integration.

Learn more at https://www.dreamfactory.com

## Quick Setup

These instructions allow you to quickly install DreamFactory 2.0 on your system and try it out. The commands shown here 
are primarily for a Linux based OS. But this should also work on Windows with all the required software and extensions installed.

> _Note: This quick setup instruction assumes that you are familiar with composer, git and the basics of how to setup a Web 
> and Database server._

#### Required software and extensions

At minimum, you will need the following software and extensions installed and enabled on your system in order to successfully 
install and run DreamFactory 2.0.

* Git
* Composer
* curl
* php5.5+ 
* php5-common
* php5-cli
* php5-curl
* php5-json
* php5-mcrypt
* php5-gd
* php5-mysqlnd
* php5-sqlite3

#### Installation


* Clone this repository to a directory on your system.
> git clone https://github.com/dreamfactorysoftware/dreamfactory.git ~/df2

* Change directory.
> cd ~/df2

* Install dependencies using composer.
> composer install --no-dev

* Run DreamFactory setup wizard. This will prompt you to create your admin user account.
> php artisan dreamfactory:setup

* Make sure your web server can read/write from/to storage/ (sub directories) and bootstrap/cache/ directories.
> Example:
>
> sudo chown -R {www user}:{your user group} storage/ bootstrap/cache/<br>
> sudo chmod -R 2775 storage/ bootstrap/cache/

* Run the following command to try out DreamFactory 2.0 without configuring a Database and Web Server. 
>php artisan serve


#### Connecting to your own Database Server

To connect to your own Database Server...

* Edit the .env file at the installation root and change the following configuration.
> DB_DRIVER=mysql     ## Supported drivers are sqlite (default), mysql, pgsql, sqlsrv<br>
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
