<?php

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

//Route::get('/user', function (Request $request) {
//    return $request->user();
//})->middleware('auth:api');

$resourcePathPattern = '[0-9a-zA-Z-_@&\#\!=,:;\/\^\$\.\|\{\}\[\]\(\)\*\+\? ]+';
$servicePattern = '[_0-9a-zA-Z-.]+';

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
