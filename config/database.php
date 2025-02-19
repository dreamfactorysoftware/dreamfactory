<?php

return [

    'connections' => [
        'sqlite' => [
            'driver' => 'sqlite',
            'database' => env('DB_DATABASE', database_path('database.sqlite')),
            'prefix' => env('DB_PREFIX', ''),
        ],

        'mysql' => [
            'driver' => 'mysql',
            'read' => env('DB_WRITE_HOST') || env('DB_READ_HOST') ? [
                'host' => [env('DB_READ_HOST')],
            ] : null,
            'write' => env('DB_WRITE_HOST') || env('DB_READ_HOST') ? [
                'host' => [env('DB_WRITE_HOST')],
            ] : null,
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '3306'),
            'database' => env('DB_DATABASE', 'dreamfactory'),
            'username' => env('DB_USERNAME', ''),
            'password' => env('DB_PASSWORD', ''),
            'charset' => env('DB_CHARSET', 'utf8mb4'),
            'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
            'prefix' => env('DB_PREFIX', ''),
            'strict' => true,
            'engine' => null,
        ],

        'pgsql' => [
            'driver' => 'pgsql',
            'url' => env('DB_URL', null),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'dreamfactory'),
            'username' => env('DB_USERNAME', ''),
            'password' => env('DB_PASSWORD', ''),
            'charset' => env('DB_CHARSET', 'utf8'),
            'prefix' => env('DB_PREFIX', ''),
            'schema' => 'public',
            'sslmode' => 'prefer',
        ],

        'sqlsrv' => [
            'driver' => 'sqlsrv',
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '1433'),
            'database' => env('DB_DATABASE', 'dreamfactory'),
            'username' => env('DB_USERNAME', ''),
            'password' => env('DB_PASSWORD', ''),
            'prefix' => env('DB_PREFIX', ''),
        ],
    ],

    'migrations' => [
        'table' => 'migrations',
        'update_date_on_publish' => false, // disable to preserve original behavior for existing applications
    ],

    'redis' => [

        'client' => env('REDIS_CLIENT', 'predis'),

        'default' => [
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'port' => env('REDIS_PORT', 6379),
            'database' => env('REDIS_DATABASE', 0),
            'password' => env('REDIS_PASSWORD', null), // Needed by Redis Cloud and other similar services
        ],

        'broadcast' => [
            'host' => env('BROADCAST_HOST', env('REDIS_HOST')),
            'port' => env('BROADCAST_PORT', env('REDIS_PORT')),
            'database' => env('BROADCAST_DATABASE', 1),
            'password' => env('BROADCAST_PASSWORD', env('REDIS_PASSWORD')),
        ],

        'cache' => [
            'host' => env('CACHE_HOST', env('REDIS_HOST')),
            'port' => env('CACHE_PORT', env('REDIS_PORT')),
            'database' => env('CACHE_DATABASE', 2),
            'password' => env('CACHE_PASSWORD', env('REDIS_PASSWORD')),
        ],

        'queue' => [
            'host' => env('QUEUE_HOST', env('REDIS_HOST')),
            'port' => env('QUEUE_PORT', env('REDIS_PORT')),
            'database' => env('QUEUE_DATABASE', 3),
            'password' => env('QUEUE_PASSWORD', env('REDIS_PASSWORD')),
        ],

    ],

    'max_records_returned' => env('DB_MAX_RECORDS_RETURNED', env('DF_DB_MAX_RECORDS_RETURNED', 100000)),

];
