# dreamfactory
DreamFactory 2.0 Application.

## Quick Setup

> **Note:** This quick setup instruction assumes that you are familiar with composer and the basics of how to setup a web and database server.

1. Clone this repository.
2. Copy .env-dist file to .env file and make necessary changes there, including specifying DB connection info. By default, it is set up to use MySQL. If you would like to use a different database, please see config/database.php file.
3. Make sure that the 'storage' and 'bootstrap/cache' directory has proper permissions so that your web server can write to it. 
4. Run composer update. This will resolve all necessary dependencies as well as point out the ones that it cannot automatically resolve.
5. And that's it! Launch a web browser and point to your web server. It should prompt you with creating an admin user. 
6. Once you create the first admin user, you can login with that user and start using DreamFactory!

> **Note:** The default composer.json has the more common package additions listed. 
To see all available packages, see the composer.json-all-dist. 
Likewise to see the minimum required packages, see the composer.json-min-dist.


More help is on the way. Please stay tuned...
