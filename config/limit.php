<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Cache Store
    |--------------------------------------------------------------------------
    |
    | This option controls the default cache connection that gets used while
    | using this caching library. This connection is used when another is
    | not explicitly specified when executing a given caching function.
    |
    | Supported: "apc", "array", "database", "file", "memcached", "redis"
    |
    */

    'default' => env('LIMIT_CACHE_DRIVER', 'file'),

    /*
    |--------------------------------------------------------------------------
    | Cache Stores
    |--------------------------------------------------------------------------
    |
    | Here you may define all of the cache "stores" for your application as
    | well as their drivers. You may even define multiple stores for the
    | same cache driver to group types of items stored in your caches.
    |
    */

    'stores' => [

        'apc' => [
            'driver' => 'apc',
        ],

        'array' => [
            'driver' => 'array',
        ],

        'database' => [
            'driver' => 'database',
            'table' => env('LIMIT_CACHE_TABLE', 'limit'),
            'connection' => env('DB_CONNECTION', 'sqlite'),
        ],

        'file' => [
            'driver' => 'file',
            'path' => env('LIMIT_CACHE_PATH', storage_path('framework/limit_cache')),
        ],

        'memcached' => [
            'driver' => 'memcached',
            'persistent_id' => env('LIMIT_CACHE_PERSISTENT_ID', env('MEMCACHED_PERSISTENT_ID')),
            'sasl' => [
                env('LIMIT_CACHE_USERNAME', env('MEMCACHED_USERNAME')),
                env('LIMIT_CACHE_PASSWORD', env('MEMCACHED_PASSWORD')),
            ],
            'options' => [
                // Memcached::OPT_CONNECT_TIMEOUT  => 2000,
            ],
            'servers' => [
                [
                    'host' => env('LIMIT_CACHE_HOST', env('MEMCACHED_HOST', '127.0.0.1')),
                    'port' => env('LIMIT_CACHE_PORT', env('MEMCACHED_PORT', 11211)),
                    'weight' => env('LIMIT_CACHE_WEIGHT', env('MEMCACHED_WEIGHT', 100)),
                ],
            ],
        ],

        'redis' => [
            'driver' => 'redis',
            'client' => env('REDIS_CLIENT', 'predis'),
            'host' => env('LIMIT_CACHE_HOST', env('LIMIT_CACHE_REDIS_HOST', env('REDIS_HOST'))),
            'port' => env('LIMIT_CACHE_PORT', env('LIMIT_CACHE_REDIS_PORT', env('REDIS_PORT'))),
            'database' => env('LIMIT_CACHE_DATABASE', env('LIMIT_CACHE_REDIS_DATABASE', 9)),
            'password' => env('LIMIT_CACHE_PASSWORD', env('LIMIT_CACHE_REDIS_PASSWORD', env('REDIS_PASSWORD'))),
        ],

        /* Managed instance limits cache */
        env('DF_LIMITS_CACHE_STORE', 'dfe-limits') => [
            'driver' => 'file',
            'path' => env('DF_LIMITS_CACHE_PATH', storage_path('framework/cache')),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Cache Key Prefix
    |--------------------------------------------------------------------------
    |
    | When utilizing a RAM based store such as APC or Memcached, there might
    | be other applications utilizing the same cache. So, we'll specify a
    | value to get prefixed to all our keys so we can avoid collisions.
    |
    */

    'prefix' => env('LIMIT_CACHE_PREFIX', 'dreamfactory'),

];
