<?php

use Illuminate\Support\Facades\Facade;
use Illuminate\Support\ServiceProvider;

return [

    'version' => '6.3.0',

    'license_key' => env('DF_LICENSE_KEY', false),

    'cipher' => env('APP_CIPHER', 'AES-256-CBC'),

    'providers' => ServiceProvider::defaultProviders()->merge([
        /*
         * Laravel Framework Service Providers...
         */

        /*
         * Application Service Providers...
         */
        DreamFactory\Providers\AppServiceProvider::class,
        //        DreamFactory\Providers\AuthServiceProvider::class, // laravel 5.3
        //        DreamFactory\Providers\BroadcastServiceProvider::class,
        //        DreamFactory\Providers\EventServiceProvider::class,
        DreamFactory\Providers\RouteServiceProvider::class,
    ])->toArray(),

    'aliases' => Facade::defaultAliases()->merge([
        'Redis' => Illuminate\Support\Facades\Redis::class,
    ])->toArray(),

];
