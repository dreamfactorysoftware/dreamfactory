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

Route::get('/', 'SplashController@index');

Route::get('launchpad', 'LaunchpadController@index');

Route::get('admin', 'AdminController@index');

Route::get('dsp/oauth/login/{provider}', 'SplashController@handleOAuthLogin');

Route::get('dsp/oauth/callback/{service}', 'SplashController@handleOAuthCallback');

Route::controllers([
    'auth'     => 'Auth\AuthController',
    'password' => 'Auth\PasswordController',
]);
