<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Queue Driver
    |--------------------------------------------------------------------------
    |
    | Laravel's queue API supports an assortment of back-ends via a single
    | API, giving you convenient access to each back-end using the same
    | syntax for each one. Here you may set the default queue driver.
    |
    | Supported: "sync", "database", "beanstalkd", "sqs", "redis", "null"
    |
    */

    'default' => env('QUEUE_CONNECTION', 'sync'),

    /*
    |--------------------------------------------------------------------------
    | Queue Connections
    |--------------------------------------------------------------------------
    |
    | Here you may configure the connection information for each server that
    | is used by your application. A default configuration has been added
    | for each back-end shipped with Laravel. You are free to add more.
    |
    */

    'connections' => [

        'sync' => [
            'driver' => 'sync',
        ],

        'database' => [
            'driver' => 'database',
            'database' => env('DB_CONNECTION', 'sqlite'),
            'table' => env('QUEUE_TABLE', 'jobs'),
            'queue' => env('QUEUE_NAME', 'default'),
            'retry_after' => env('QUEUE_RETRY_AFTER', 90),
        ],

        'beanstalkd' => [
            'driver' => 'beanstalkd',
            'host' => env('QUEUE_HOST', 'localhost'),
            'queue' => env('QUEUE_NAME', 'default'),
            'retry_after' => env('QUEUE_RETRY_AFTER', 90),
        ],

        'sqs' => [
            'driver' => 'sqs',
            'key' => env('AWS_ACCESS_KEY_ID'),
            'secret' => env('AWS_SECRET_ACCESS_KEY'),
            'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
            'prefix' => env('SQS_PREFIX', 'https://sqs.us-east-1.amazonaws.com/your-account-id'),
            'queue' => env('QUEUE_NAME', 'default'),
        ],

        'redis' => [
            'driver' => 'redis',
            'connection' => 'queue',
            'queue' => env('QUEUE_NAME', 'default'),
            'retry_after' => env('QUEUE_RETRY_AFTER', 90),
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Failed Queue Jobs
    |--------------------------------------------------------------------------
    |
    | These options configure the behavior of failed queue job logging so you
    | can control which database and table are used to store the jobs that
    | have failed. You may change them to any database / table you wish.
    |
    */

    'failed' => [
        'database' => env('DB_CONNECTION', 'sqlite'),
        'table' => 'failed_jobs',
    ],

];
