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

//Treat merge as patch
$method = Request::getMethod();
if (\DreamFactory\Library\Utility\Enums\Verbs::MERGE === strtoupper($method)) {
    Request::setMethod(\DreamFactory\Library\Utility\Enums\Verbs::PATCH);
}

Route::get('/', 'SplashController@index');

Route::get('/setup', 'SplashController@createFirstUser');

Route::post('/setup', 'SplashController@createFirstUser');

Route::get('/setup_db', 'SplashController@setupDb');

Route::post('/setup_db', 'SplashController@setupDb');

$resourcePathPattern = '[0-9a-zA-Z-_@&\#\!=,:;\/\^\$\.\|\{\}\[\]\(\)\*\+\? ]+';
$servicePattern = '[_0-9a-zA-Z-.]+';

Route::group(
    ['prefix' => 'api'],
    function () use ($resourcePathPattern, $servicePattern){
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
    function () use ($resourcePathPattern, $servicePattern){
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

Route::get('{storage}/{path}', 'StorageController@handleGET')->where(
    ['storage' => $servicePattern, 'path' => $resourcePathPattern]
);

