<?php
namespace DreamFactory\Http\Controllers;

use DreamFactory\Core\Models\User;
use DreamFactory\Library\Utility\Enums\Verbs;
use DreamFactory\Core\Components\Registrar;
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
        $request = \Request::instance();
        $method = $request->method();

        if (Verbs::GET === $method) {
            if (!User::adminExists()) {
                $data = [
                    'version'    => \Config::get('df.api_version'),
                    'email'      => '',
                    'name'       => '',
                    'first_name' => '',
                    'last_name'  => ''
                ];

                return view('firstUser', $data);
            } else {
                return redirect()->to('/');
            }
        } else if (Verbs::POST === $method) {
            $data = $request->all();
            $registrar = new Registrar();
            $validator = $registrar->validator($data);

            if ($validator->fails()) {
                $errors = $validator->getMessageBag()->all();
                $data = array_merge($data, ['errors' => $errors, 'version' => \Config::get('df.api_version')]);

                return view('firstUser', $data);
            } else {
                $registrar->createFirstAdmin($data);

                return redirect()->to('/');
            }
        }
    }

    /**
     * Sets up db by running migration and seeder.
     *
     * @return \Illuminate\Http\RedirectResponse
     */
    public function setupDb()
    {
        $setup = \Cache::get('setup_db', false);
        if(!$setup){
            return redirect()->to('/');
        }

        $request = \Request::instance();
        $method = $request->method();

        if(Verbs::GET === $method){
            return view('setup', [
                'version' => config('df.api_version')
            ]);
        } else if(Verbs::POST === $method) {
            try {
                $setup = \Cache::pull('setup_db', false);
                if ($setup) {
                    \Artisan::call('migrate');
                    \Artisan::call('db:seed');

                    if ($request->ajax()) {
                        echo json_encode(['success' => true, 'redirect_path' => '/setup']);
                    } else {
                        return redirect()->to('/setup');
                    }
                } else {
                    if ($request->ajax()) {
                        echo json_encode([
                            'success' => false,
                            'message' => 'Setup not required. System is already setup'
                        ]);
                    } else {
                        return redirect()->to('/');
                    }
                }
            } catch (\Exception $e) {
                if ($request->ajax()) {
                    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
                } else {
                    return view(
                        'errors.generic',
                        [
                            'error' => $e->getMessage(),
                            'version' => config('df.api_version')
                        ]
                    );
                }
            }
        }
    }
}