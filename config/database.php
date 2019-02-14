<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Database Connection Name
    |--------------------------------------------------------------------------
    |
    | Here you may specify which of the database connections below you wish
    | to use as your default connection for all database work. Of course
    | you may use many connections at once using the Database library.
    |
    */

    'default' => env('DB_CONNECTION', env('DB_DRIVER', 'sqlite')),

    /*
    |--------------------------------------------------------------------------
    | Database Connections
    |--------------------------------------------------------------------------
    |
    | Here are each of the database connections setup for your application.
    | Of course, examples of configuring each database platform that is
    | supported by Laravel is shown below to make development simple.
    |
    |
    | All database work in Laravel is done through the PHP PDO facilities
    | so make sure you have the driver for your particular database of
    | choice installed on your machine before you begin development.
    |
    */

    'connections' => [

        'sqlite' => [
            'driver'   => 'sqlite',
            'database' => env('DB_DATABASE', database_path('database.sqlite')),
            'prefix'   => env('DB_PREFIX', ''),
        ],

        'mysql' => [
            'driver'    => 'mysql',
            'host'      => env('DB_HOST', '127.0.0.1'),
            'port'      => env('DB_PORT', '3306'),
            'database'  => env('DB_DATABASE', 'dreamfactory'),
            'username'  => env('DB_USERNAME', ''),
            'password'  => env('DB_PASSWORD', ''),
            'charset'   => env('DB_CHARSET', 'utf8mb4'),
            'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
            'prefix'    => env('DB_PREFIX', ''),
            'strict'    => true,
            'engine'    => null,
        ],

        'pgsql' => [
            'driver'   => 'pgsql',
            'url'      => env('DATABASE_URL', null),
            'host'     => env('DB_HOST', '127.0.0.1'),
            'port'     => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'dreamfactory'),
            'username' => env('DB_USERNAME', ''),
            'password' => env('DB_PASSWORD', ''),
            'charset'  => env('DB_CHARSET', 'utf8'),
            'prefix'   => env('DB_PREFIX', ''),
            'schema'   => 'public',
            'sslmode'  => 'prefer',
        ],

        'sqlsrv' => [
            'driver'   => 'sqlsrv',
            'host'     => env('DB_HOST', '127.0.0.1'),
            'port'     => env('DB_PORT', '1433'),
            'database' => env('DB_DATABASE', 'dreamfactory'),
            'username' => env('DB_USERNAME', ''),
            'password' => env('DB_PASSWORD', ''),
            'prefix'   => env('DB_PREFIX', ''),
        ],

        'logsdb' => [
            'driver'   => 'mongodb',
            'host'     => env('LOGSDB_HOST', 'localhost'),
            'port'     => env('LOGSDB_PORT', 27017),
            'database' => env('LOGSDB_DATABASE'),
            'username' => env('LOGSDB_USERNAME'),
            'password' => env('LOGSDB_PASSWORD'),
            'options'  => [
                'database' => 'admin' // sets the authentication database required by mongo 3
            ]
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Migration Repository Table
    |--------------------------------------------------------------------------
    |
    | This table keeps track of all the migrations that have already run for
    | your application. Using this information, we can determine which of
    | the migrations on disk haven't actually been run in the database.
    |
    */

    'migrations' => 'migrations',

    /*
    |--------------------------------------------------------------------------
    | Redis Databases
    |--------------------------------------------------------------------------
    |
    | Redis is an open source, fast, and advanced key-value store that also
    | provides a richer set of commands than a typical key-value systems
    | such as APC or Memcached. Laravel makes it easy to dig right in.
    |
    */

    'redis' => [

        'client' => env('REDIS_CLIENT', 'predis'),

        'default' => [
            'host'     => env('REDIS_HOST', '127.0.0.1'),
            'port'     => env('REDIS_PORT', 6379),
            'database' => env('REDIS_DATABASE', 0),
            'password' => env('REDIS_PASSWORD', null), // Needed by Redis Cloud and other similar services
        ],

        'broadcast' => [
            'host'     => env('BROADCAST_HOST', env('REDIS_HOST')),
            'port'     => env('BROADCAST_PORT', env('REDIS_PORT')),
            'database' => env('BROADCAST_DATABASE', 1),
            'password' => env('BROADCAST_PASSWORD', env('REDIS_PASSWORD')),
        ],

        'cache' => [
            'host'     => env('CACHE_HOST', env('REDIS_HOST')),
            'port'     => env('CACHE_PORT', env('REDIS_PORT')),
            'database' => env('CACHE_DATABASE', 2),
            'password' => env('CACHE_PASSWORD', env('REDIS_PASSWORD')),
        ],

        'queue' => [
            'host'     => env('QUEUE_HOST', env('REDIS_HOST')),
            'port'     => env('QUEUE_PORT', env('REDIS_PORT')),
            'database' => env('QUEUE_DATABASE', 3),
            'password' => env('QUEUE_PASSWORD', env('REDIS_PASSWORD')),
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Default Max Records Returned
    |--------------------------------------------------------------------------
    |
    | This value keeps clients from crashing the system with large database
    | queries. It can be overridden by individual database service
    | configurations.
    |
    */

    'max_records_returned' => env('DB_MAX_RECORDS_RETURNED', env('DF_DB_MAX_RECORDS_RETURNED', 100000)),

];
