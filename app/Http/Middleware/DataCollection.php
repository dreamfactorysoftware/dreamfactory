<?php namespace Dreamfactory\Http\Middleware;

use Closure;
use DreamFactory\Core\Utility\Session;
use DreamFactory\Managed\Support\Managed;

class DataCollection
{
    //******************************************************************************
    //* Methods
    //******************************************************************************

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
        //  Send the audit data
        //Managed::auditRequest($request, Session::getPublicInfo());

        return $next($request);
    }
}
