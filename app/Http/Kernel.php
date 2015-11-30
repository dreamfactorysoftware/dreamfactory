<?php
namespace DreamFactory\Http;

use DreamFactory\Http\Middleware\AccessCheck;
use DreamFactory\Http\Middleware\Cors;
use DreamFactory\Http\Middleware\FirstUserCheck;
use DreamFactory\Managed\Bootstrap\ManagedInstance;
use Illuminate\Auth\Middleware\AuthenticateWithBasicAuth;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Kernel as HttpKernel;
use Illuminate\Foundation\Http\Middleware\CheckForMaintenanceMode;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;
use DreamFactory\Http\Middleware\AuthCheck;

class Kernel extends HttpKernel
{
    /**
     * The application's global HTTP middleware stack.
     *
     * @var array
     */
    protected $middleware = [
        CheckForMaintenanceMode::class,
        EncryptCookies::class,
        AddQueuedCookiesToResponse::class,
        StartSession::class,
        ShareErrorsFromSession::class,
        FirstUserCheck::class,
        Cors::class,
        AuthCheck::class,
    ];

    /**
     * The application's route middleware.
     *
     * @var array
     */
    protected $routeMiddleware = [
        'auth.basic'   => AuthenticateWithBasicAuth::class,
        'access_check' => AccessCheck::class,
    ];

    //******************************************************************************
    //* Methods
    //******************************************************************************

    /**
     * Inject our bootstrapper into the mix
     */
    protected function bootstrappers()
    {
        $_stack = parent::bootstrappers();

        //  Insert our guy
        array_unshift($_stack, array_shift($_stack), ManagedInstance::class);

        return $_stack;
    }
}
