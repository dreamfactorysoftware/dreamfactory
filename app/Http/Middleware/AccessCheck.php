<?php
namespace DreamFactory\Http\Middleware;

use Closure;
use DreamFactory\Core\Enums\VerbsMask;
use DreamFactory\Core\Exceptions\BadRequestException;
use DreamFactory\Core\Exceptions\ForbiddenException;
use DreamFactory\Core\Exceptions\UnauthorizedException;
use DreamFactory\Core\Models\Role;
use DreamFactory\Core\Models\Service;
use DreamFactory\Core\User\Services\User;
use DreamFactory\Core\Utility\ResponseFactory;
use DreamFactory\Core\Utility\Session;
use DreamFactory\Library\Utility\ArrayUtils;
use Illuminate\Http\Request;
use Illuminate\Routing\Router;

class AccessCheck
{
    protected static $exceptions = [
        [
            'verb_mask' => 31, //Allow all verbs
            'service'   => 'system',
            'resource'  => 'admin/session',
        ],
        [
            'verb_mask' => 31, //Allow all verbs
            'service'   => 'user',
            'resource'  => 'session',
        ],
        [
            'verb_mask' => 2, //Allow POST only
            'service'   => 'user',
            'resource'  => 'password',
        ],
        [
            'verb_mask' => 2, //Allow POST only
            'service'   => 'system',
            'resource'  => 'admin/password',
        ],
        [
            'verb_mask' => 1,
            'service'   => 'system',
            'resource'  => 'environment',
        ],
        [
            'verb_mask' => 15,
            'service'   => 'user',
            'resource'  => 'profile',
        ],
    ];

    /**
     * @param Request $request
     * @param Closure $next
     *
     * @return array|mixed|string
     */
    public function handle($request, Closure $next)
    {
        //  Allow console requests through
        if (env('DF_IS_VALID_CONSOLE_REQUEST', false)) {
            return $next($request);
        }

        try {
            static::setExceptions();

            if (static::isAccessAllowed()) {
                return $next($request);
            } elseif (static::isException($request)) {
                //API key and/or (non-admin) user logged in, but if access is still not allowed then check for exception case.
                return $next($request);
            } else {
                $apiKey = Session::getApiKey();
                $token = Session::getSessionToken();

                if (empty($apiKey) && empty($token)) {
                    throw new BadRequestException('Bad request. No token or api key provided.');
                } elseif (true === Session::get('token_expired')) {
                    throw new UnauthorizedException(Session::get('token_expired_msg'));
                } elseif (true === Session::get('token_blacklisted')) {
                    throw new ForbiddenException(Session::get('token_blacklisted_msg'));
                } elseif (true === Session::get('token_invalid')) {
                    throw new BadRequestException(Session::get('token_invalid_msg'), 401);
                } else if (!Role::getCachedInfo(Session::getRoleId(), 'is_active')) {
                    throw new ForbiddenException("Role is not active.");
                } elseif (!Session::isAuthenticated()) {
                    throw new UnauthorizedException('Unauthorized.');
                } else {
                    throw new ForbiddenException('Access Forbidden.');
                }
            }
        } catch (\Exception $e) {
            return ResponseFactory::getException($e, $request);
        }
    }

    /**
     * Checks to see if it is an admin user login call.
     *
     * @param  \Illuminate\Http\Request $request
     *
     * @return bool
     * @throws \DreamFactory\Core\Exceptions\NotImplementedException
     */
    protected static function isException($request)
    {
        /** @var Router $router */
        $router = app('router');
        $service = strtolower($router->input('service'));
        $resource = strtolower($router->input('resource'));
        $action = VerbsMask::toNumeric($request->getMethod());

        foreach (static::$exceptions as $exception) {
            if (($action & ArrayUtils::get($exception, 'verb_mask')) &&
                $service === ArrayUtils::get($exception, 'service') &&
                $resource === ArrayUtils::get($exception, 'resource')
            ) {
                return true;
            }
        }

        return false;
    }

    /**
     * Checks to see if Access is Allowed based on Role-Service-Access.
     *
     * @return bool
     * @throws \DreamFactory\Core\Exceptions\NotImplementedException
     */
    public static function isAccessAllowed()
    {
        /** @var Router $router */
        $router = app('router');
        $service = strtolower($router->input('service'));
        $component = strtolower($router->input('resource'));
        $action = VerbsMask::toNumeric(\Request::getMethod());
        $allowed = Session::getServicePermissions($service, $component);

        return ($action & $allowed) ? true : false;
    }

    protected static function setExceptions()
    {
        if (class_exists(User::class)) {
            $userService = Service::getCachedByName('user');

            if ($userService['config']['allow_open_registration']) {
                static::$exceptions[] = [
                    'verb_mask' => 2, //Allow POST only
                    'service'   => 'user',
                    'resource'  => 'register',
                ];
            }
        }
    }
}
