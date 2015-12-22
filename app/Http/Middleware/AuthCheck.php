<?php
namespace DreamFactory\Http\Middleware;

use Auth;
use JWTAuth;
use DreamFactory\Core\Utility\JWTUtilities;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenBlacklistedException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Tymon\JWTAuth\Payload;
use Illuminate\Http\Request;
use DreamFactory\Core\Utility\Session;
use DreamFactory\Core\Models\App;
use DreamFactory\Core\Exceptions\UnauthorizedException;
use DreamFactory\Core\Models\User;
use DreamFactory\Core\Utility\ResponseFactory;
use DreamFactory\Library\Utility\ArrayUtils;

class AuthCheck
{
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
        $token = static::getJWTFromAuthHeader();
        if (empty($token)) {
            $token = $request->header('X_DREAMFACTORY_SESSION_TOKEN');
        }
        if (empty($token)) {
            $token = $request->input('session_token');
        }
        if (empty($token)) {
            $token = $request->input('token');
        }

        return $token;
    }

    /**
     * Gets the token from Authorization header.
     *
     * @return string
     */
    protected static function getJWTFromAuthHeader()
    {
        if ('testing' === env('APP_ENV')) {
            //getallheaders method is not available in unit test mode.
            return [];
        }

        if (!function_exists('getallheaders')) {
            function getallheaders()
            {
                if (!is_array($_SERVER)) {
                    return [];
                }

                $headers = [];
                foreach ($_SERVER as $name => $value) {
                    if (substr($name, 0, 5) == 'HTTP_') {
                        $headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] =
                            $value;
                    }
                }

                return $headers;
            }
        }

        $token = null;
        $headers = getallheaders();
        $authHeader = ArrayUtils::get($headers, 'Authorization');
        if (strpos($authHeader, 'Bearer') !== false) {
            $token = substr($authHeader, 7);
        }

        return $token;
    }

    /**
     * @param Request  $request
     * @param \Closure $next
     *
     * @return array|mixed|string
     */
    public function handle(Request $request, \Closure $next)
    {
        if (!in_array($route = $request->getPathInfo(), ['/setup', '/setup_db',])) {
            try {
                $apiKey = static::getApiKey($request);
                Session::setApiKey($apiKey);
                $appId = App::getAppIdByApiKey($apiKey);

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
                        throw new UnauthorizedException('Unauthorized. User credentials did not match.');
                    }
                } elseif (!empty($token)) {
                    //JWT supplied meaning an authenticated user session/token.

                    /**
                     * Note: All caught exception from JWT are stored in session variables.
                     * These are later checked and handled appropriately in the AccessCheck middleware.
                     *
                     * This is to allow processing API calls that do not require any valid
                     * authenticated session. For example POST user/session to login,
                     * PUT user/session to refresh old JWT, GET system/environment etc.
                     *
                     * This also allows for auditing API calls that are called by not permitted/processed.
                     * It also allows counting unauthorized API calls against Enterprise Console limits.
                     */
                    try {
                        JWTAuth::setToken($token);
                        /** @type Payload $payload */
                        $payload = JWTAuth::getPayload();
                        JWTUtilities::verifyUser($payload);
                        $userId = $payload->get('user_id');
                        Session::setSessionData($appId, $userId);
                    } catch (TokenExpiredException $e) {
                        JWTUtilities::clearAllExpiredTokenMaps();
                        Session::set('token_expired', true);
                        Session::set('token_expired_msg', $e->getMessage());
                    } catch (TokenBlacklistedException $e) {
                        Session::set('token_blacklisted', true);
                        Session::set('token_blacklisted_msg', $e->getMessage());
                    } catch (TokenInvalidException $e) {
                        Session::set('token_invalid', true);
                        Session::set('token_invalid_msg', 'Invalid token: ' . $e->getMessage());
                    }
                } elseif (!empty($apiKey)) {
                    //Just Api Key is supplied. No authenticated session
                    Session::setSessionData($appId);
                }

                return $next($request);
            } catch (\Exception $e) {
                return ResponseFactory::getException($e, $request);
            }
        }

        return $next($request);
    }
}