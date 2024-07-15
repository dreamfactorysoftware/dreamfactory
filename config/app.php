<?php

use Illuminate\Support\Facades\Facade;
use Illuminate\Support\ServiceProvider;

return [

    'version' => '6.3.0',

    'license_key' => env('DF_LICENSE_KEY', false),

    'cipher' => env('APP_CIPHER', 'AES-256-CBC'),


    'aliases' => Facade::defaultAliases()->merge([
        'Redis' => Illuminate\Support\Facades\Redis::class,
    ])->toArray(),

];
