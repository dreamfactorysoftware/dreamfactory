<?php namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Controllers\SplashController;
use DreamFactory\Rave\Models\Service;
use Illuminate\Contracts\Auth\Guard;
use Illuminate\Foundation\Auth\AuthenticatesAndRegistersUsers;
use DreamFactory\Rave\Components\Registrar;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AuthController extends Controller {

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
     * @param  \Illuminate\Contracts\Auth\Guard  $auth
     */
    public function __construct(Guard $auth)
    {
        $this->auth = $auth;
        $this->registrar = new Registrar();

        $this->middleware('guest', ['except' => ['getLogout', 'getRegister', 'postRegister']]);
    }

    /**
     * Show the application registration form.
     *
     * @return \Illuminate\Http\Response
     */
    public function getRegister()
    {
        $auth = \Auth::check();
        $user = \Auth::getUser();

        if($auth && !empty($user) && $user->is_sys_admin)
        {
            return view( 'auth.register' );
        }
        else{
            return view('nonadmin');
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
        $facebookOauths = Service::whereType('oauth_facebook')->get()->toArray();
        $twitterOauths = Service::whereType('oauth_twitter')->get()->toArray();
        $githubOauths = Service::whereType('oauth_github')->get()->toArray();
        $googleOauths = Service::whereType('oauth_google')->get()->toArray();
        $ldaps = Service::whereType('ldap')->get()->toArray();

        $data = [
            'facebook' => count($facebookOauths)>0? $facebookOauths : [],
            'twitter' => count($twitterOauths)>0? $twitterOauths : [],
            'github' => count($githubOauths)>0? $githubOauths : [],
            'google' => count($googleOauths)>0? $googleOauths : [],
            'ldap' => count($ldaps)>0? $ldaps : [],
            'oauth_url' => '//'.\Request::getHost().'/dsp/oauth/login/'
        ];

        return view('auth.login', $data);
    }

    /**
     * Handle a login request to the application.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function postLogin(Request $request)
    {
        $submit = $request->input('submit');

        if('dsp' !== $submit)
        {
            return SplashController::handleLdapLogin($submit);
        }

        $this->validate($request, [
            'email' => 'required|email', 'password' => 'required',
        ]);

        $credentials = $request->only('email', 'password');

        //if user management not available then only system admins can login.
        if(!class_exists('\DreamFactory\Rave\User\Resources\System\User'))
        {
            $credentials['is_sys_admin'] = 1;
        }

        if ($this->auth->attempt($credentials, $request->has('remember')))
        {
            $user = \Auth::getUser();
            $user->update(['last_login_date' => Carbon::now()->toDateTimeString()]);
            return redirect()->intended($this->redirectPath());
        }

        return redirect($this->loginPath())
            ->withInput($request->only('email', 'remember'))
            ->withErrors([
                             'email' => $this->getFailedLoginMessage(),
                         ]);
    }


    /**
     * Handle a registration request for the application.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function postRegister(Request $request)
    {
        $validator = $this->registrar->validator($request->all());

        if ($validator->fails())
        {
            $this->throwValidationException(
                $request, $validator
            );
        }

        $user = $this->registrar->create($request->all());

        if(!\Auth::check())
        {
            $this->auth->login( $user );
        }

        return redirect($this->redirectPath());
    }
}
