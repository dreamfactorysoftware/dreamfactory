<?php

use DreamFactory\Http\Controllers\SplashController;
use Illuminate\Support\Facades\Route;

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

Route::middleware(['web'])->group(function () {
    Route::get('/', [SplashController::class, 'index']);
    Route::get('/setup', [SplashController::class, 'createFirstUser']);
    Route::post('/setup', [SplashController::class, 'createFirstUser']);
    Route::get('/setup_db', [SplashController::class, 'setupDb']);
    Route::post('/setup_db', [SplashController::class, 'setupDb']);
});
