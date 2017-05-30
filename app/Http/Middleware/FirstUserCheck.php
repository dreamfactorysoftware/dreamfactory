<?php
namespace DreamFactory\Http\Middleware;

use Closure;
use DreamFactory\Core\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;

class FirstUserCheck
{
    /**
     * @param Request  $request
     * @param \Closure $next
     *
     * @return \Illuminate\Http\RedirectResponse
     * @throws \Exception
     */
    public function handle($request, Closure $next)
    {
        if (!in_array($route = $request->getPathInfo(), ['/setup', '/setup_db'])) {
            try {
                if (!User::adminExists()) {
                    return redirect()->to('/setup');
                } elseif (!empty(config('df.package_path'))) {
                    if (false === \Cache::get('package_imported', false)) {
                        \Artisan::call('df:import-pkg');
                        \Cache::forever('package_imported', true);
                    }
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
