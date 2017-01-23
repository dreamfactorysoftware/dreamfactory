<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

//Route::get('/', function () {
//    return view('welcome');
//});

Route::get('/', 'SplashController@index');

Route::get('/setup', 'SplashController@createFirstUser');

Route::post('/setup', 'SplashController@createFirstUser');

Route::get('/setup_db', 'SplashController@setupDb');

Route::post('/setup_db', 'SplashController@setupDb');

Route::get('/status', 'StatusController@index');

$resourcePathPattern = '[0-9a-zA-Z-_@&\#\!=,:;\/\^\$\.\|\{\}\[\]\(\)\*\+\? ]+';
$servicePattern = '[_0-9a-zA-Z-.]+';

Route::get('{storage}/{path}', 'StorageController@handleGET')->where(
    ['storage' => $servicePattern, 'path' => $resourcePathPattern]
);
