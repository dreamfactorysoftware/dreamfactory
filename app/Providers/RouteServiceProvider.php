<?php
namespace DreamFactory\Providers;

use Illuminate\Support\Facades\Route;
use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Request;

class RouteServiceProvider extends ServiceProvider
{
    /**
     * This namespace is applied to your controller routes.
     *
     * In addition, it is set as the URL generator's root namespace.
     *
     * @var string
     */
    protected $namespace = 'DreamFactory\Http\Controllers';

    /**
     * Define your route model bindings, pattern filters, etc.
     *
     * @return void
     */
    public function boot()
    {
        //

        parent::boot();
    }

    /**
     * Define the routes for the application.
     *
     * @return void
     */
    public function map()
    {
        if (env('DF_MANAGED', false)) {
            /*
             * Controller route to allow the Enterprise Console to talk to instances.
             * If this route is removed or disabled Enterprise functions will break
             */
            // todo this needs to be upgraded to work
            Route::controller('/instance', '\DreamFactory\Managed\Http\Controllers\InstanceController');
        }

        $this->mapApiRoutes();

        $this->mapWebRoutes();
    }

    /**
     * Define the "web" routes for the application.
     *
     * These routes all receive session state, CSRF protection, etc.
     *
     * @return void
     */
    protected function mapWebRoutes()
    {
        Route::group([
            'middleware' => 'web',
            'namespace'  => $this->namespace,
        ], function ($router) {
            require base_path('routes/web.php');
        });
    }

    /**
     * Define the "api" routes for the application.
     *
     * These routes are typically stateless.
     *
     * @return void
     */
    protected function mapApiRoutes()
    {
        /* Check for verb tunneling by the various method override headers or query params
         * Tunnelling verb overrides:
         *      X-Http-Method (Microsoft)
         *      X-Http-Method-Override (Google/GData)
         *      X-Method-Override (IBM)
         * Symfony natively supports X-HTTP-METHOD-OVERRIDE header and "_method" URL parameter
         * we just need to add our historical support for other options, including "method" URL parameter
         */
        Request::enableHttpMethodParameterOverride(); // enables _method URL parameter
        $method = Request::getMethod();
        if (('POST' === $method) &&
            (!empty($dfOverride = Request::header('X-HTTP-Method',
                Request::header('X-Method-Override', Request::query('method')))))
        ) {
            Request::setMethod($method = strtoupper($dfOverride));
        }
// support old MERGE as PATCH
        if ('MERGE' === strtoupper($method)) {
            Request::setMethod('PATCH');
        }

        Route::group([
            'middleware' => 'api',
            'namespace'  => $this->namespace,
            'prefix'     => 'api',
        ], function ($router) {
            require base_path('routes/api.php');
        });

        // Old V1 routes
        Route::group([
            'middleware' => 'api',
            'namespace'  => $this->namespace,
            'prefix'     => 'rest',
        ], function ($router) {
            require base_path('routes/rest.php');
        });
    }
}
