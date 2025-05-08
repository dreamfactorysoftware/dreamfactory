<?php

use Illuminate\Support\Facades\Facade;

return [

    'version' => '7.1.0',

    'license_key' => env('DF_LICENSE_KEY', false),

    'cipher' => env('APP_CIPHER', 'AES-256-CBC'),

    'aliases' => Facade::defaultAliases()->merge([
        'Redis' => Illuminate\Support\Facades\Redis::class,
    ])->toArray(),

    'providers' => [
        // DreamFactory Providers FIRST
        DreamFactory\Core\File\ServiceProvider::class,    // This needs to be before SessionServiceProvider
        DreamFactory\Core\LaravelServiceProvider::class,
        
        // Laravel Framework Service Providers...
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
        Illuminate\Session\SessionServiceProvider::class,  // This needs the File ServiceProvider
        Illuminate\Translation\TranslationServiceProvider::class,
        Illuminate\Validation\ValidationServiceProvider::class,
        Illuminate\View\ViewServiceProvider::class,

        // Add MongoDB Provider (with correct namespace)
        MongoDB\Laravel\MongoDBServiceProvider::class,

        // Other DreamFactory Providers
        DreamFactory\Providers\AuthServiceProvider::class,
    ],

];
