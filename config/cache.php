<?php

use Illuminate\Support\Str;

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

    'default' => env('CACHE_DRIVER', 'file'),

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
            'table' => env('CACHE_TABLE', 'cache'),
            'connection' => env('DB_CONNECTION', 'sqlite'),
        ],

        'file' => [
            'driver' => 'file',
            'path' => env('CACHE_PATH', env('DF_CACHE_PATH', storage_path('framework/cache/data'))),
        ],

        'memcached'  => [
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

        'redis' => [
            'driver' => 'redis',
            'connection' => 'cache',
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

    'prefix' => env('CACHE_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_cache'),

    /*
    |--------------------------------------------------------------------------
    | Cache Default Time To Live
    |--------------------------------------------------------------------------
    |
    | When the application does not specify a TTL, use this instead.
    |
    */

    'default_ttl' => env('CACHE_DEFAULT_TTL', env('DF_CACHE_TTL', 18000)), // old env for upgrades

];
