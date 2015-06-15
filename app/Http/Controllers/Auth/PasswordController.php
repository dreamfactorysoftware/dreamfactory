<?php namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use DreamFactory\Core\Resources\System\Password;
use DreamFactory\Core\Resources\UserPasswordResource;
use Illuminate\Contracts\Auth\Guard;
use Illuminate\Contracts\Auth\PasswordBroker;
use Illuminate\Foundation\Auth\ResetsPasswords;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Illuminate\Http\Request;
use Response;

class PasswordController extends Controller
{

    /*
    |--------------------------------------------------------------------------
    | Password Reset Controller
    |--------------------------------------------------------------------------
    |
    | This controller is responsible for handling password reset requests
    | and uses a simple trait to include this behavior. You're free to
    | explore this trait and override any methods you wish to tweak.
    |
    */

    use ResetsPasswords;

    protected $redirectTo = '/launchpad';

    /**
     * Create a new password controller instance.
     *
     * @param  \Illuminate\Contracts\Auth\Guard          $auth
     * @param  \Illuminate\Contracts\Auth\PasswordBroker $passwords
     */
    public function __construct( Guard $auth, PasswordBroker $passwords )
    {
        $this->auth = $auth;
        $this->passwords = $passwords;

        $this->middleware( 'guest' );
    }

    /**
     * Display the form to request a password reset link.
     *
     * @return Response
     */
    public function getEmail()
    {
        return view( 'auth.password' );
    }

    /**
     * Display the password reset view for the given token.
     *
     * @param  string $token
     *
     * @return Response
     */
    public function getReset( $token = null )
    {
        if ( is_null( $token ) )
        {
            throw new NotFoundHttpException;
        }

        return view( 'auth.reset' )->with( 'token', $token );
    }

    /**
     * Reset the given user's password.
     *
     * @param  Request $request
     *
     * @return Response
     */
    public function postReset( Request $request )
    {
        $this->validate(
            $request,
            [
                'token'    => 'required',
                'email'    => 'required|email',
                'password' => 'required|confirmed',
            ]
        );

        try
        {
            UserPasswordResource::changePasswordByCode( $request->input( 'email' ), urldecode( $request->input( 'token' ) ), $request->input( 'password' ) );

            return redirect( $this->redirectPath() );
        }
        catch ( \Exception $e )
        {
            return redirect()->back()->withInput( $request->only( 'email' ) )->withErrors( [ 'email' => trans( $e->getMessage() ) ] );
        }
    }
}
