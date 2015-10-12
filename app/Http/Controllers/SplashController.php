<?php
namespace DreamFactory\Http\Controllers;

use DreamFactory\Core\Models\User;
use DreamFactory\Library\Utility\Enums\Verbs;
use Validator;
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
        return redirect(config('df.landing_page', '/test_rest.html'));
    }

    public function createFirstUser()
    {
        if (!User::adminExists()) {
            $request = \Request::instance();
            $method = $request->method();

            if (Verbs::GET === $method) {
                $data = [
                    'version'    => \Config::get('df.api_version'),
                    'email'      => '',
                    'name'       => '',
                    'first_name' => '',
                    'last_name'  => ''
                ];

                return view('firstUser', $data);
            } else if (Verbs::POST === $method) {
                $data = $request->all();
                $user = User::createFirstAdmin($data);

                if (!$user) {
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

            if (Verbs::GET === $method) {
                return view('setup', [
                    'version' => config('df.api_version')
                ]);
            } else if (Verbs::POST === $method) {
                try {
                    if (\Cache::pull('setup_db', false)) {
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
                                'message' => 'Setup not required. System is already setup'
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
                                'version' => config('df.api_version')
                            ]
                        );
                    }
                }
            }
        }

        return redirect()->to('/');
    }
}