<?php

// load up any providers specific to DreamFactory
$dfProviders = [
    DreamFactory\Core\LaravelServiceProvider::class,
];

if (class_exists('DreamFactory\Core\ADLdap\ServiceProvider')) {
    $dfProviders[] = \DreamFactory\Core\ADLdap\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\ApiDoc\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\ApiDoc\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Aws\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Aws\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Azure\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Azure\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\AzureAD\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\AzureAD\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Cache\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Cache\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Cassandra\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Cassandra\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Couchbase\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Couchbase\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\CouchDb\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\CouchDb\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Database\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Database\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Email\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Email\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\File\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\File\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Firebird\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Firebird\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Git\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Git\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\IbmDb2\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\IbmDb2\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Informix\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Informix\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Limit\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Limit\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Logger\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Logger\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\MongoDb\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\MongoDb\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\MQTT\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\MQTT\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Notification\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Notification\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\OAuth\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\OAuth\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Oidc\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Oidc\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Oracle\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Oracle\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Rackspace\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Rackspace\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Rws\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Rws\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Salesforce\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Salesforce\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Saml\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Saml\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Script\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Script\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\Soap\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\Soap\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\SqlAnywhere\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\SqlAnywhere\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\SqlDb\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\SqlDb\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\SqlSrv\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\SqlSrv\ServiceProvider::class;
}
if (class_exists('DreamFactory\Core\User\ServiceProvider')) {
    $dfProviders[] = DreamFactory\Core\User\ServiceProvider::class;
}

return [

    /*
    |--------------------------------------------------------------------------
    | Application Version
    |--------------------------------------------------------------------------
    |
    | This is the version of your application, not the version of the API.
    */

    'version' => '2.8.1',

    /*
    |--------------------------------------------------------------------------
    | Application Name
    |--------------------------------------------------------------------------
    |
    | This value is the name of your application. This value is used when the
    | framework needs to place the application's name in a notification or
    | any other location as required by the application or its packages.
    */

    'name' => env('APP_NAME', 'DreamFactory'),

    /*
    |--------------------------------------------------------------------------
    | Application Environment
    |--------------------------------------------------------------------------
    |
    | This value determines the "environment" your application is currently
    | running in. This may determine how you prefer to configure various
    | services your application utilizes. Set this in your ".env" file.
    |
    */

    'env' => env('APP_ENV', 'production'),

    /*
    |--------------------------------------------------------------------------
    | Application Debug Mode
    |--------------------------------------------------------------------------
    |
    | When your application is in debug mode, detailed error messages with
    | stack traces will be shown on every error that occurs within your
    | application. If disabled, a simple generic error page is shown.
    |
    */

    'debug' => env('APP_DEBUG', false),

    /*
    |--------------------------------------------------------------------------
    | Application URL
    |--------------------------------------------------------------------------
    |
    | This URL is used by the console to properly generate URLs when using
    | the Artisan command line tool. You should set this to the root of
    | your application so that it is used when running Artisan tasks.
    |
    */

    'url' => env('APP_URL', 'http://localhost'),

    /*
    |--------------------------------------------------------------------------
    | Application Timezone
    |--------------------------------------------------------------------------
    |
    | Here you may specify the default timezone for your application, which
    | will be used by the PHP date and date-time functions. We have gone
    | ahead and set this to a sensible default for you out of the box.
    |
    */

    'timezone' => env('APP_TIMEZONE', 'UTC'),

    /*
    |--------------------------------------------------------------------------
    | Application Locale Configuration
    |--------------------------------------------------------------------------
    |
    | The application locale determines the default locale that will be used
    | by the translation service provider. You are free to set this value
    | to any of the locales which will be supported by the application.
    |
    */

    'locale' => env('APP_LOCALE', 'en'),

    /*
    |--------------------------------------------------------------------------
    | Application Fallback Locale
    |--------------------------------------------------------------------------
    |
    | The fallback locale determines the locale to use when the current one
    | is not available. You may change the value to correspond to any of
    | the language folders that are provided through your application.
    |
    */

    'fallback_locale' => 'en',

    /*
    |--------------------------------------------------------------------------
    | Encryption Key
    |--------------------------------------------------------------------------
    |
    | This key is used by the Illuminate encrypter service and should be set
    | to a random, 32 character string, otherwise these encrypted strings
    | will not be safe. Please do this before deploying an application!
    |
    */

    'key' => env('APP_KEY'),

    'cipher' => env('APP_CIPHER', 'AES-256-CBC'),

    /*
    |--------------------------------------------------------------------------
    | Logging Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure the log settings for your application. Out of
    | the box, Laravel uses the Monolog PHP logging library. This gives
    | you a variety of powerful log handlers / formatters to utilize.
    |
    | Available Settings: "single", "daily", "syslog", "errorlog"
    |
    */

    'log' => env('APP_LOG', 'single'),

    'log_level' => env('APP_LOG_LEVEL', 'warning'),

    /*
    |--------------------------------------------------------------------------
    | Autoloaded Service Providers
    |--------------------------------------------------------------------------
    |
    | The service providers listed here will be automatically loaded on the
    | request to your application. Feel free to add your own services to
    | this array to grant expanded functionality to your applications.
    |
    */

    'providers' => array_merge([

        /*
         * Laravel Framework Service Providers...
         */
        Illuminate\Auth\AuthServiceProvider::class,
        Illuminate\Broadcasting\BroadcastServiceProvider::class,
        Illuminate\Bus\BusServiceProvider::class,
        Illuminate\Cache\CacheServiceProvider::class,
        Illuminate\Foundation\Providers\ConsoleSupportServiceProvider::class,
        Illuminate\Cookie\CookieServiceProvider::class,
        Illuminate\Database\DatabaseServiceProvider::class,
        Illuminate\Encryption\EncryptionServiceProvider::class,
        Illuminate\Filesystem\FilesystemServiceProvider::class,
        Illuminate\Foundation\Providers\FoundationServiceProvider::class,
        Illuminate\Hashing\HashServiceProvider::class,
        Illuminate\Mail\MailServiceProvider::class,
        Illuminate\Notifications\NotificationServiceProvider::class,
        Illuminate\Pagination\PaginationServiceProvider::class,
        Illuminate\Pipeline\PipelineServiceProvider::class,
        Illuminate\Queue\QueueServiceProvider::class,
        Illuminate\Redis\RedisServiceProvider::class,
        Illuminate\Auth\Passwords\PasswordResetServiceProvider::class,
        Illuminate\Session\SessionServiceProvider::class,
        Illuminate\Translation\TranslationServiceProvider::class,
        Illuminate\Validation\ValidationServiceProvider::class,
        Illuminate\View\ViewServiceProvider::class,

        /*
         * Application Service Providers...
         */
        DreamFactory\Providers\AppServiceProvider::class,
//        DreamFactory\Providers\AuthServiceProvider::class, // laravel 5.3
//        DreamFactory\Providers\BroadcastServiceProvider::class,
//        DreamFactory\Providers\EventServiceProvider::class,
        DreamFactory\Providers\RouteServiceProvider::class,

        /*
         * Uncomment the following line to generate IDE helper
         * using "php artisan ide-helper:generate" command,
         */
        //Barryvdh\LaravelIdeHelper\IdeHelperServiceProvider::class,

    ], $dfProviders),

    /*
    |--------------------------------------------------------------------------
    | Class Aliases
    |--------------------------------------------------------------------------
    |
    | This array of class aliases will be registered when this application
    | is started. However, feel free to register as many as you wish as
    | the aliases are "lazy" loaded so they don't hinder performance.
    |
    */

    'aliases' => [

        'App' => Illuminate\Support\Facades\App::class,
        'Artisan' => Illuminate\Support\Facades\Artisan::class,
        'Auth' => Illuminate\Support\Facades\Auth::class,
        'Blade' => Illuminate\Support\Facades\Blade::class,
        'Broadcast' => Illuminate\Support\Facades\Broadcast::class,
        'Bus' => Illuminate\Support\Facades\Bus::class,
        'Cache' => Illuminate\Support\Facades\Cache::class,
        'Config' => Illuminate\Support\Facades\Config::class,
        'Cookie' => Illuminate\Support\Facades\Cookie::class,
        'Crypt' => Illuminate\Support\Facades\Crypt::class,
        'DB' => Illuminate\Support\Facades\DB::class,
        'Eloquent' => Illuminate\Database\Eloquent\Model::class,
        'Event' => Illuminate\Support\Facades\Event::class,
        'File' => Illuminate\Support\Facades\File::class,
        'Gate' => Illuminate\Support\Facades\Gate::class,
        'Hash' => Illuminate\Support\Facades\Hash::class,
        'Lang' => Illuminate\Support\Facades\Lang::class,
        'Log' => Illuminate\Support\Facades\Log::class,
        'Mail' => Illuminate\Support\Facades\Mail::class,
        'Notification' => Illuminate\Support\Facades\Notification::class,
        'Password' => Illuminate\Support\Facades\Password::class,
        'Queue' => Illuminate\Support\Facades\Queue::class,
        'Redirect' => Illuminate\Support\Facades\Redirect::class,
        'Redis' => Illuminate\Support\Facades\Redis::class,
        'Request' => Illuminate\Support\Facades\Request::class,
        'Response' => Illuminate\Support\Facades\Response::class,
        'Route' => Illuminate\Support\Facades\Route::class,
        'Schema' => Illuminate\Support\Facades\Schema::class,
        'Session' => Illuminate\Support\Facades\Session::class,
        'Storage' => Illuminate\Support\Facades\Storage::class,
        'URL' => Illuminate\Support\Facades\URL::class,
        'Validator' => Illuminate\Support\Facades\Validator::class,
        'View' => Illuminate\Support\Facades\View::class,

    ],

];
