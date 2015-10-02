<?php

namespace DreamFactory\Http\Middleware;

use DreamFactory\Core\Models\User;
use Illuminate\Database\QueryException;
use Closure;

class FirstUserCheck
{
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
        $route = $request->getPathInfo();

        if ('/setup' !== $route && '/setup_db' !== $route) {
            try {
                if (!User::adminExists()) {
                    return redirect()->to('/setup');
                }
            } catch (QueryException $e) {
                $code = $e->getCode();

                if ($code === '42S02') {
                    //Mysql base table or view not found.
                    \Cache::put('setup_db', true, config('df.default_cache_ttl'));

                    return redirect()->to('/setup_db');
                } else {
                    throw $e;
                }
            }
        }

        return $next($request);
    }
}