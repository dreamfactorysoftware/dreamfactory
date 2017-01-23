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

$resourcePathPattern = '[0-9a-zA-Z-_@&\#\!=,:;\/\^\$\.\|\{\}\[\]\(\)\*\+\? ]+';
$servicePattern = '[_0-9a-zA-Z-.]+';

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
