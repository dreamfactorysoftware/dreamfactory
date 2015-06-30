<?php
namespace DreamFactory\Http\Controllers;

use Response;
use Carbon\Carbon;
use DreamFactory\Core\OAuth\Services\BaseOAuthService;
use DreamFactory\Core\Utility\ServiceHandler;
use DreamFactory\Core\ADLdap\Services\LDAP as LdapService;
use DreamFactory\Core\ADLdap\Contracts\Provider as ADLdapProvider;
use DreamFactory\Core\Utility\Session;
use Laravel\Socialite\Contracts\Provider;
use Laravel\Socialite\Contracts\User;

class SplashController extends Controller
{
    /**
     * Create new splash screen controller.
     */
    public function __construct()
    {
        $this->middleware('guest');
    }

    /**
     * Show the application splash screen to the user.
     *
     * @return Response
     */
    public function index()
    {
        return redirect(env('LANDING_PAGE', '/launchpad'));
    }
}