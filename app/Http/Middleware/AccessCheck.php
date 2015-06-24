<?php
namespace DreamFactory\Http\Middleware;

use \Auth;
use \Closure;
use \JWTAuth;
use Illuminate\Http\Request;
use Illuminate\Routing\Router;
use DreamFactory\Core\Enums\VerbsMask;
use DreamFactory\Library\Utility\ArrayUtils;
use DreamFactory\Core\Exceptions\BadRequestException;
use DreamFactory\Core\Exceptions\ForbiddenException;
use DreamFactory\Core\Exceptions\UnauthorizedException;
use DreamFactory\Core\Utility\ResponseFactory;
use DreamFactory\Core\Models\Role;
use DreamFactory\Core\Models\User;
use DreamFactory\Core\Utility\Session;
use DreamFactory\Core\Utility\CacheUtilities;
use Tymon\JWTAuth\Payload;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;

class AccessCheck
{
    protected static $exceptions = [
        [
            'verb_mask' => 31, //Allow all verbs
            'service'   => 'system',
            'resource'  => 'admin/session'
        ],
        [
            'verb_mask' => 31, //Allow all verbs
            'service'   => 'user',
            'resource'  => 'session'
        ],
        [
            'verb_mask' => 2, //Allow POST only
            'service'   => 'user',
            'resource'  => 'password'
        ],
        [
            'verb_mask' => 2, //Allow POST only
            'service'   => 'system',
            'resource'  => 'admin/password'
        ],
        [
            'verb_mask' => 1,
            'service'   => 'system',
            'resource'  => 'environment'
        ]
    ];

    /**
     * @param Request $request
     *
     * @return mixed
     */
    public static function getApiKey($request)
    {
        //Check for API key in request parameters.
        $apiKey = $request->query('api_key');
        if (empty($apiKey)) {
            //Check for API key in request HEADER.
            $apiKey = $request->header('X_DREAMFACTORY_API_KEY');
        }

        return $apiKey;
    }

    /**
     * @param Request $request
     *
     * @return mixed
     */
    public static function getJwt($request)
    {
        return $request->header('X_DREAMFACTORY_SESSION_TOKEN');
    }

    /**
     * @param Request  $request
     * @param callable $next
     *
     * @return array|mixed|string
     */
    public function handle($request, Closure $next)
    {
        //Get the api key.
        $apiKey = static::getApiKey($request);
        $appId = CacheUtilities::getAppIdByApiKey($apiKey);

        //Get the JWT.
        $token = static::getJwt($request);
        Session::setSessionToken($token);

        //Check for basic auth attempt.
        $basicAuthUser = $request->getUser();
        $basicAuthPassword = $request->getPassword();

        if (!empty($basicAuthUser) && !empty($basicAuthPassword)) {
            //Attempting to login using basic auth.
            Auth::onceBasic();
            /** @var User $authenticatedUser */
            $authenticatedUser = Auth::user();
            if (!empty($authenticatedUser)) {
                $userId = $authenticatedUser->id;
                Session::setSessionData($appId, $userId);
            } else {
                return static::getException(
                    new UnauthorizedException('Unauthorized. User credentials did not match.'),
                    $request
                );
            }
        } elseif (!empty($token)) {
            //JWT supplied meaning an authenticated user session/token.
            try {
                JWTAuth::setToken($token);
                /** @type Payload $payload */
                $payload = JWTAuth::getPayload();
                $userId = $payload->get('user_id');
                Session::setSessionData($appId, $userId);
            } catch (TokenExpiredException $e) {
                return static::getException(new UnauthorizedException($e->getMessage()), $request);
            }
        } elseif (!empty($apiKey)) {
            //Just Api Key is supplied. No authenticated session
            Session::setSessionData($appId);
        } elseif (static::isException($request)) {
            //Path exception.
            return $next($request);
        } else {
            //No token and/or Api Key supplied.
            return static::getException(
                new BadRequestException('Bad request. No token or api key provided.'),
                $request
            );
        }

        if (Session::isAccessAllowed()) {
            return $next($request);
        } elseif (static::isException($request)) {
            //API key and/or (non-admin) user logged in, but if access is still not allowed then check for exception case.
            return $next($request);
        } else {
            if (!Session::isAuthenticated()) {
                return static::getException(
                    new UnauthorizedException('Unauthorized.'),
                    $request
                );
            } else {
                return static::getException(new ForbiddenException('Access Forbidden.'), $request);
            }
        }
    }

    /**
     * @param \Exception               $e
     * @param \Illuminate\Http\Request $request
     *
     * @return array|mixed|string
     */
    protected static function getException($e, $request)
    {
        $response = ResponseFactory::create($e);
        $accepts = explode(',', $request->header('ACCEPT'));

        return ResponseFactory::sendResponse($response, $accepts);
    }

    /**
     * Generates the role data array using the role model.
     *
     * @param Role $role
     *
     * @return array
     */
    protected static function getRoleData(Role $role)
    {
        $rsa = $role->getRoleServiceAccess();

        $roleData = [
            'name'     => $role->name,
            'id'       => $role->id,
            'services' => $rsa
        ];

        return $roleData;
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
}