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
}