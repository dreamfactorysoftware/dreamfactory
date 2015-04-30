<?php
/**
 * This file is part of the DreamFactory Rave(tm)
 *
 * DreamFactory Rave(tm) <http://github.com/dreamfactorysoftware/rave>
 * Copyright 2012-2014 DreamFactory Software, Inc. <support@dreamfactory.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace App\Http\Controllers;

use Socialize;
use Response;

class SplashController extends Controller
{
    /**
     * Create new splash screen controller.
     */
    public function __construct()
    {
        $this->middleware('guest');
    }

    /**
     * Show the application splash screen to the user.
     *
     * @return Response
     */
    public function index()
    {
        return view('splash');
    }

    public function redirectToProvider()
    {
        return Socialize::with('facebook')->redirect();
    }

    public function handleProviderCallback()
    {
        $user = Socialize::with('facebook')->user();

        echo "<pre>";
        print_r($user->user);
        echo "</pre>";
    }
}