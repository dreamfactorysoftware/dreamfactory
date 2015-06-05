<?php namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Controllers\SplashController;
use DreamFactory\Rave\Models\Service;
use DreamFactory\Rave\Utility\Session;
use DreamFactory\Rave\Components\Registrar;
use Illuminate\Contracts\Auth\Guard;
use Illuminate\Foundation\Auth\AuthenticatesAndRegistersUsers;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AuthController extends Controller
{

    /*
    |--------------------------------------------------------------------------
    | Registration & Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles the registration of new users, as well as the
    | authentication of existing users. By default, this controller uses
    | a simple trait to add these behaviors. Why don't you explore it?
    |
    */

    use AuthenticatesAndRegistersUsers;

    protected $redirectTo = '/launchpad';

    protected $loginPath = '/auth/login';

    protected $redirectAfterLogout = '/';

    /**
     * Create a new authentication controller instance.
     *
     * @param  \Illuminate\Contracts\Auth\Guard $auth
     */
    public function __construct( Guard $auth )
    {
        $this->auth = $auth;
        $this->registrar = new Registrar();

        $this->middleware( 'guest', [ 'except' => [ 'getLogout', 'getRegister', 'postRegister' ] ] );
    }

    /**
     * Show the application registration form.
     *
     * @return \Illuminate\Http\Response
     */
    public function getRegister()
    {
        $auth = \Auth::check();
        $user = \Auth::user();

        if ( $auth && !empty( $user ) && $user->is_sys_admin )
        {
            return view( 'auth.register' );
        }
        else
        {
            return view( 'nonadmin' );
        }
    }

    /**
     * Show the application login form.
     *
     * @return \Illuminate\Http\Response
     */
    public function getLogin()
    {
        return $this->loadLoginView();
    }

    /**
     * Configures and loads the login view
     *
     * @return \Illuminate\View\View
     */
    protected function loadLoginView()
    {
        $oauth = Service::whereIn(
            'type',
            [ 'oauth_facebook', 'oauth_twitter', 'oauth_github', 'oauth_google' ]
        )->whereIsActive( 1 )->get()->toArray();

        $ldap = Service::whereIn(
            'type',
            [ 'ldap', 'adldap' ]
        )->whereIsActive( 1 )->get()->toArray();

        $data = [
            'oauth'     => count( $oauth ) > 0 ? $oauth : [ ],
            'ldap'      => count( $ldap ) > 0 ? $ldap : [ ],
            'oauth_url' => '//' . \Request::getHost() . '/dsp/oauth/login/'
        ];

        return view( 'auth.login', $data );
    }

    /**
     * Handle a login request to the application.
     *
     * @param  \Illuminate\Http\Request $request
     *
     * @return \Illuminate\Http\Response
     */
    public function postLogin( Request $request )
    {
        $submit = $request->input( 'submit' );

        if ( 'dsp' !== $submit )
        {
            return SplashController::handleADLdapLogin( $submit );
        }

        $this->validate(
            $request,
            [
                'email'    => 'required|email',
                'password' => 'required',
            ]
        );

        $credentials = $request->only( 'email', 'password' );

        //if user management not available then only system admins can login.
        if ( !class_exists( '\DreamFactory\Rave\User\Resources\System\User' ) )
        {
            $credentials['is_sys_admin'] = 1;
        }

        //Only active users are allowed to login.
        $credentials['is_active'] = 1;

        if ( $this->auth->attempt( $credentials, $request->has( 'remember' ) ) )
        {
            $user = \Auth::user();
            $user->update( [ 'last_login_date' => Carbon::now()->toDateTimeString() ] );
            Session::setUserInfo( $user );

            return redirect()->intended( $this->redirectPath() );
        }

        return redirect( $this->loginPath() )->withInput( $request->only( 'email', 'remember' ) )->withErrors(
            [
                'email' => $this->getFailedLoginMessage(),
            ]
        );
    }

    /**
     * Handle a registration request for the application.
     *
     * @param  \Illuminate\Http\Request $request
     *
     * @return \Illuminate\Http\Response
     */
    public function postRegister( Request $request )
    {
        $validator = $this->registrar->validator( $request->all() );

        if ( $validator->fails() )
        {
            $this->throwValidationException(
                $request,
                $validator
            );
        }

        $user = $this->registrar->create( $request->all() );

        if ( !\Auth::check() )
        {
            $this->auth->login( $user );
        }

        return redirect( $this->redirectPath() );
    }
}
