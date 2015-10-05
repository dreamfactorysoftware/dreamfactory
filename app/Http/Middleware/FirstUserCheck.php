<?php

namespace DreamFactory\Http\Middleware;

use DreamFactory\Core\Models\User;
use Illuminate\Database\QueryException;
use Closure;

class FirstUserCheck
{
    /**
     * @param          $request
     * @param \Closure $next
     *
     * @return \Illuminate\Http\RedirectResponse
     * @throws \Exception
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
                try {
                    //base table or view not found.
                    \Cache::put('setup_db', true, config('df.default_cache_ttl'));

                    return redirect()->to('/setup_db');
                } catch (\Exception $ex) {
                    throw $ex;
                }
            }
        }

        return $next($request);
    }
}