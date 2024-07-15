<?php

use Illuminate\Support\Str;

return [

    'stores' => [
        'file' => [
            'driver' => 'file',
            'path' => env('CACHE_PATH', env('DF_CACHE_PATH', storage_path('framework/cache/data'))),
        ],

        'memcached' => [
            'driver' => 'memcached',
            'persistent_id' => env('CACHE_PERSISTENT_ID', env('MEMCACHED_PERSISTENT_ID')),
            'sasl' => [
                env('CACHE_USERNAME', env('MEMCACHED_USERNAME')),
                env('CACHE_PASSWORD', env('MEMCACHED_PASSWORD')),
            ],
            'options' => [
                // Memcached::OPT_CONNECT_TIMEOUT  => 2000,
            ],
            'servers' => [
                [
                    'host' => env('CACHE_HOST', env('MEMCACHED_HOST', '127.0.0.1')),
                    'port' => env('CACHE_PORT', env('MEMCACHED_PORT', 11211)),
                    'weight' => env('CACHE_WEIGHT', env('MEMCACHED_WEIGHT', 100)),
                ],
            ],
        ],
    ],

    'default_ttl' => env('CACHE_DEFAULT_TTL', env('DF_CACHE_TTL', 18000)), // old env for upgrades

];
