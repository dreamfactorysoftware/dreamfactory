<?php

namespace DreamFactory\Http\Middleware;

use DreamFactory\Core\Utility\CacheUtilities;
use Illuminate\Contracts\Routing\Middleware;
use Illuminate\Database\QueryException;
use Closure;

class FirstUserCheck implements Middleware
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

        if ('/setup' !== $route) {
            try {
                if (!CacheUtilities::adminExists()) {
                    return redirect()->to('/setup');
                }
            } catch (QueryException $e) {
                $code = $e->getCode();

                if($code === '42S02') {
                    //Mysql base table or view not found.
                    \Artisan::call('migrate');
                    \Artisan::call('db:seed');

                    return redirect()->to('/setup');
                } else {
                    throw $e;
                }
            }
        }

        return $next($request);
    }
}