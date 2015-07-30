<?php

namespace DreamFactory\Http\Middleware;

use DreamFactory\Core\Utility\CacheUtilities;
use Illuminate\Contracts\Routing\Middleware;
use Closure;
use Illuminate\Database\QueryException;

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
                \Artisan::call('migrate');
                \Artisan::call('db:seed');

                return redirect()->to('/setup');
            }
        }

        return $next($request);
    }
}