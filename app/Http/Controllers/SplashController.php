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
//        return view( 'splash' );
    }

    /**
     * Handles OAuth login redirects.
     *
     * @param $provider
     *
     * @return \Symfony\Component\HttpFoundation\RedirectResponse
     * @throws \DreamFactory\Core\Exceptions\ForbiddenException
     * @throws \DreamFactory\Core\Exceptions\NotFoundException
     */
    public function handleOAuthLogin($provider)
    {
        /** @var BaseOAuthService $service */
        $service = ServiceHandler::getService($provider);

        /** @var Provider $driver */
        $driver = $service->getDriver();

        return $driver->redirect();
    }

    /**
     * Performs ldap login
     *
     * @param $provider
     *
     * @return $this|\Illuminate\Http\RedirectResponse
     * @throws \DreamFactory\Core\Exceptions\BadRequestException
     * @throws \DreamFactory\Core\Exceptions\ForbiddenException
     * @throws \DreamFactory\Core\Exceptions\NotFoundException
     * @throws \Exception
     */
    public static function handleADLdapLogin($provider)
    {
        $username = \Request::input('email');
        $password = \Request::input('password');

        if (!empty($username) && !empty($password)) {
            /** @var LdapService $service */
            $service = ServiceHandler::getService($provider);

            /** @var ADLdapProvider $driver */
            $driver = $service->getDriver();

            $auth = $driver->authenticate($username, $password);

            if ($auth) {
                $ldapUser = $driver->getUser();
                $user = $service->createShadowADLdapUser($ldapUser);
                $user->update(['last_login_date' => Carbon::now()->toDateTimeString()]);

                \Auth::login($user, \Request::has('remember'));
                Session::setUserInfo($user->toArray());

                return redirect()->intended(env('LANDING_PAGE', '/launchpad'));
            }
        }

        return redirect('/auth/login')->withInput(\Request::only('email', 'remember'))->withErrors(
            [
                'email' => 'Invalid username and password.',
            ]
        );
    }

    /**
     * Handles OAuth callback from the provider after
     * successful authentication.
     *
     * @param string $serviceName
     *
     * @return array|\Illuminate\Http\RedirectResponse
     * @throws \DreamFactory\Core\Exceptions\ForbiddenException
     * @throws \DreamFactory\Core\Exceptions\NotFoundException
     * @throws \Exception
     */
    public function handleOAuthCallback($serviceName)
    {
        /** @var BaseOAuthService $service */
        $service = ServiceHandler::getService($serviceName);

        /** @var Provider $driver */
        $driver = $service->getDriver();

        /** @var User $user */
        $user = $driver->user();

        $dfUser = $service->createShadowOAuthUser($user);
        $dfUser->update(['last_login_date' => Carbon::now()->toDateTimeString()]);

        \Auth::login($dfUser);
        Session::setUserInfo($dfUser->toArray());

        if (\Request::ajax()) {
            return ['success' => true, 'session_id' => Session::getId()];
        } else {
            return redirect()->intended(env('LANDING_PAGE', '/launchpad'));
        }
    }
}