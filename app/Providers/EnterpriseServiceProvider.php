<?php
namespace DreamFactory\Providers;

use Illuminate\Support\ServiceProvider;
use DreamFactory\Core\Utility\Enterprise;


class EnterpriseServiceProvider extends ServiceProvider
{
    /**
     * Indicates if loading of the provider is deferred.
     *
     * @var bool
     */
    protected $defer = true;

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
        $this->app->singleton('dfe.initialize', function($app) {
           return Enterprise::initialize();
        });
    }

    public function provides()
    {
        return ['dfe.initialize'];
    }
}
