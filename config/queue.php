<?php

return [

    'connections' => [
        'database' => [
            'driver' => 'database',
            'database' => env('DB_CONNECTION', 'sqlite'),
            'table' => env('QUEUE_TABLE', 'jobs'),
            'queue' => env('QUEUE_NAME', 'default'),
            'retry_after' => env('QUEUE_RETRY_AFTER', 90),
            'connection' => env('DB_QUEUE_CONNECTION'),
            'after_commit' => false,
        ],
    ],

];
