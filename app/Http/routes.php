<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the controller to call when that URI is requested.
|
*/

/* Check for verb tunneling by the various method override headers or query params
 * Tunnelling verb overrides:
 *      X-Http-Method (Microsoft)
 *      X-Http-Method-Override (Google/GData)
 *      X-Method-Override (IBM)
 * Symfony natively supports X-HTTP-METHOD-OVERRIDE header and "_method" URL parameter
 * we just need to add our historical support for other options, including "method" URL parameter
 */
Request::enableHttpMethodParameterOverride(); // enables _method URL parameter
$method = Request::getMethod();
if (('POST' === $method) &&
    (!empty($dfOverride = Request::header('X-HTTP-Method',
        Request::header('X-Method-Override', Request::query('method')))))
) {
    Request::setMethod($method = strtoupper($dfOverride));
}
// support old MERGE as PATCH
if ('MERGE' === strtoupper($method)) {
    Request::setMethod('PATCH');
}

Route::get('/', 'SplashController@index');

Route::get('/setup', 'SplashController@createFirstUser');

Route::post('/setup', 'SplashController@createFirstUser');

Route::get('/setup_db', 'SplashController@setupDb');

Route::post('/setup_db', 'SplashController@setupDb');

Route::get('/status', 'StatusController@index');

$resourcePathPattern = '[0-9a-zA-Z-_@&\#\!=,:;\/\^\$\.\|\{\}\[\]\(\)\*\+\? ]+';
$servicePattern = '[_0-9a-zA-Z-.]+';

Route::group(
    ['prefix' => 'api'],
    function () use ($resourcePathPattern, $servicePattern) {
        Route::get('{version}/', 'RestController@index');
        Route::get('{version}/{service}/{resource?}', 'RestController@handleGET')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
        Route::post('{version}/{service}/{resource?}', 'RestController@handlePOST')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
        Route::put('{version}/{service}/{resource?}', 'RestController@handlePUT')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
        Route::patch('{version}/{service}/{resource?}', 'RestController@handlePATCH')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
        Route::delete('{version}/{service}/{resource?}', 'RestController@handleDELETE')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
    }
);

Route::group(
    ['prefix' => 'rest'],
    function () use ($resourcePathPattern, $servicePattern) {
        Route::get('/', 'RestController@index');
        Route::get('{service}/{resource?}', 'RestController@handleV1GET')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
        Route::post('{service}/{resource?}', 'RestController@handleV1POST')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
        Route::put('{service}/{resource?}', 'RestController@handleV1PUT')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
        Route::patch('{service}/{resource?}', 'RestController@handleV1PATCH')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
        Route::delete('{service}/{resource?}', 'RestController@handleV1DELETE')->where(
            ['service' => $servicePattern, 'resource' => $resourcePathPattern]
        );
    }
);

/**
 * Controller route to allow the Enterprise Console to talk to instances.  If this route is removed or disabled
 * Enterprise functions will break
 */
if (env('DF_MANAGED', false)) {
    Route::controller('/instance', '\DreamFactory\Managed\Http\Controllers\InstanceController');
}

Route::get('{storage}/{path}', 'StorageController@handleGET')->where(
    ['storage' => $servicePattern, 'path' => $resourcePathPattern]
);

