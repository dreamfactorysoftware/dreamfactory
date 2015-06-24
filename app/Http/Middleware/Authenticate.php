<?php namespace DreamFactory\Http\Middleware;

use Closure;
use JWTAuth;
use Illuminate\Contracts\Auth\Guard;
use DreamFactory\Core\Utility\Session;

class Authenticate
{

    /**
     * The Guard implementation.
     *
     * @var Guard
     */
    protected $auth;

    /**
     * Create a new filter instance.
     *
     * @param  Guard $auth
     */
    public function __construct(Guard $auth)
    {
        $this->auth = $auth;
    }

    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request $request
     * @param  \Closure                 $next
     *
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        if ($this->auth->guest()) {
            if ($request->ajax()) {
                return response('Unauthorized.', 401);
            } else {
                $token = $request->input('token');
                if(!empty($token)){
                    JWTAuth::setToken($token);
                    /** @type Payload $payload */
                    $payload = JWTAuth::getPayload();
                    $userId = $payload->get('user_id');
                    Session::setSessionData(null, $userId);
                }
                else {
                    return redirect()->guest('/auth/login');
                }
            }
        }

        return $next($request);
    }
}
