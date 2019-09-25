<?php

namespace DreamFactory\Http\Controllers;

use DreamFactory\Core\Enums\Verbs;
use DreamFactory\Core\Models\User;
use DreamFactory\Core\Utility\Session;
use Illuminate\Support\Arr;
use Response;

class SplashController extends Controller
{
    /**
     * Show the application splash screen to the user.
     *
     * @return Response
     */
    public function index()
    {
        $token = \Request::input('session_token');
        $param = '';
        if (! empty($token)) {
            $param = '?session_token='.$token;
        }

        return redirect(config('df.landing_page', '/test_rest.html').$param);
    }

    public function createFirstUser()
    {
        if (! User::adminExists()) {
            $request = \Request::instance();
            $method = $request->method();
            $data = [
                'username_placeholder' => 'Username (Optional, defaults to email address)',
                'email_placeholder'    => 'Email Address (Required for login)',
            ];
            $loginAttribute = strtolower(config('df.login_attribute', 'email'));
            if ($loginAttribute === 'username') {
                $data['username_placeholder'] = 'Username (Required for login)';
                $data['email_placeholder'] = 'Email Address';
            }

            if (Verbs::GET === $method) {
                $data = array_merge([
                    'version'    => \Config::get('app.version'),
                    'email'      => '',
                    'name'       => '',
                    'first_name' => '',
                    'last_name'  => '',
                    'username'   => '',
                    'errors'     => [],
                ], $data);

                return view('firstUser', $data);
            } elseif (Verbs::POST === $method) {
                $data = array_merge($request->all(), $data);
                $user = User::createFirstAdmin($data);

                if (! $user) {
                    return view('firstUser', $data);
                }

                $jwt = null;
                if (true === $login = Session::setUserInfoWithJWT($user)) {
                    $sessionInfo = Session::getPublicInfo();
                    $jwt = Arr::get($sessionInfo, 'session_token');
                }
            }
        }

        if (! empty($jwt)) {
            return redirect()->to('/?session_token='.$jwt);
        } else {
            return redirect()->to('/');
        }
    }

    /**
     * Sets up db by running migration and seeder.
     *
     * @return \Illuminate\Http\RedirectResponse
     */
    public function setupDb()
    {
        if (\Cache::get('setup_db', false)) {
            $request = \Request::instance();
            $method = $request->method();

            if (Verbs::GET === $method) {
                return view('setup', [
                    'version' => config('app.version'),
                ]);
            } elseif (Verbs::POST === $method) {
                try {
                    if (\Cache::pull('setup_db', false)) {
                        if (! file_exists(base_path('.env'))) {
                            copy(base_path('.env-dist'), base_path('.env'));
                        }

                        if (empty(env('APP_KEY'))) {
                            \Artisan::call('key:generate');
                        }

                        \Artisan::call('migrate', ['--force' => true]);
                        \Artisan::call('db:seed', ['--force' => true]);

                        if ($request->ajax()) {
                            return json_encode(['success' => true, 'redirect_path' => '/setup']);
                        } else {
                            return redirect()->to('/setup');
                        }
                    } else {
                        if ($request->ajax()) {
                            return json_encode([
                                'success' => false,
                                'message' => 'Setup not required. System is already setup',
                            ]);
                        }
                    }
                } catch (\Exception $e) {
                    if ($request->ajax()) {
                        return json_encode(['success' => false, 'message' => $e->getMessage()]);
                    } else {
                        return view(
                            'errors.generic',
                            [
                                'error'   => $e->getMessage(),
                                'version' => config('app.version'),
                            ]
                        );
                    }
                }
            }
        }

        return redirect()->to('/');
    }
}
