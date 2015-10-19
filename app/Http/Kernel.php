<?php namespace DreamFactory\Http;

use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
    /**
     * The application's global HTTP middleware stack.
     *
     * @var array
     */
    protected $middleware = [
        'Illuminate\Foundation\Http\Middleware\CheckForMaintenanceMode',
        'Illuminate\Cookie\Middleware\EncryptCookies',
        'Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse',
        'Illuminate\Session\Middleware\StartSession',
        'Illuminate\View\Middleware\ShareErrorsFromSession',
        'DreamFactory\Http\Middleware\FirstUserCheck',
        'DreamFactory\Http\Middleware\Cors'
        //'DreamFactory\Http\Middleware\VerifyCsrfToken',
    ];

    /**
     * The application's route middleware.
     *
     * @var array
     */
    protected $routeMiddleware = [
        'auth'            => 'DreamFactory\Http\Middleware\Authenticate',
        'auth.basic'      => 'Illuminate\Auth\Middleware\AuthenticateWithBasicAuth',
        'guest'           => 'DreamFactory\Http\Middleware\RedirectIfAuthenticated',
        'data_collection' => 'DreamFactory\Http\Middleware\DataCollection',
        'api_limits'      => 'DreamFactory\Http\Middleware\Limits',
        'access_check'    => 'DreamFactory\Http\Middleware\AccessCheck',
    ];

}
