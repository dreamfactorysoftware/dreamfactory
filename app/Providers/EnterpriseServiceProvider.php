<?php
namespace DreamFactory\Providers;

use DreamFactory\Core\Utility\CacheUtilities;
use Illuminate\Support\ServiceProvider;
use DreamFactory\Core\Utility\Enterprise;


class EnterpriseServiceProvider extends ServiceProvider
{
    public function boot()
    {
        Enterprise::initialize();
        config(['df.storage_path' => Enterprise::getStoragePath()]);
        config(['database.connections.dreamfactory' => Enterprise::getDatabaseConfig()]);
    }

    /**
     * Register any application services.
     *
     * This service provider is a great spot to register your various container
     * bindings with the application. As you can see, we are registering our
     * "Registrar" implementation here. You can add your own bindings too!
     *
     * @return void
     */
    public function register()
    {

    }
}
