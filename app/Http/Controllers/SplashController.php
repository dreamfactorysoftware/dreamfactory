<?php

namespace DreamFactory\Http\Controllers;

use DreamFactory\Core\Enums\Verbs;
use DreamFactory\Core\Models\User;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Http\Request;

class SplashController extends Controller
{
    /**
     * Show the application splash screen to the user.
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

    public function createFirstUser(Request $request)
    {
        if (!User::adminExists()) {
            $method = $request->method();
            $version = config('app.version');
            $data = [
                'username_placeholder' => 'Username (Optional, defaults to email address)',
                'email_placeholder' => 'Email Address (Required for login)',
                'version' => $version,
            ];
            $loginAttribute = strtolower(config('df.login_attribute', 'email'));
            if ($loginAttribute === 'username') {
                $data['username_placeholder'] = 'Username (Required for login)';
                $data['email_placeholder'] = 'Email Address';
            }

            if ($method === Verbs::GET) {
                $data = array_merge([
                    'email' => '',
                    'name' => '',
                    'first_name' => '',
                    'last_name' => '',
                    'username' => '',
                    'errors' => [],
                    'phone' => '',
                ], $data);

                return view('firstUser', $data);
            } elseif ($method === Verbs::POST) {
                try {
                    $data = array_merge($request->all(), $data);
                    $user = User::createFirstAdmin($data);

                    if (!$user) {
                        return view('firstUser', $data);
                    }

                    // Clear all caches
                    \Cache::flush();
                    \Artisan::call('config:clear');
                    \Artisan::call('route:clear');
                    
                    return redirect()->to('/');
                } catch (\Exception $e) {
                    \Log::error('Error creating first admin: ' . $e->getMessage());
                    $data['errors'] = [$e->getMessage()];
                    return view('firstUser', $data);
                }
            }
        }

        return redirect()->to('/');
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

            if ($method === Verbs::GET) {
                return view('setup', [
                    'version' => config('app.version'),
                ]);
            } elseif ($method === Verbs::POST) {
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
                                'error' => $e->getMessage(),
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
