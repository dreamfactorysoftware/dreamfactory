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

use Response;
use Carbon\Carbon;
use DreamFactory\DSP\OAuth\Services\BaseOAuthService;
use DreamFactory\Rave\Utility\ServiceHandler;
use DreamFactory\Rave\Models\User as DspUser;
use DreamFactory\DSP\ADLdap\Services\LDAP as LdapService;
use DreamFactory\DSP\ADLdap\Contracts\Provider as ADLdapProvider;
use Laravel\Socialite\Contracts\Provider;
use Laravel\Socialite\Contracts\User;

class SplashController extends Controller
{
    /**
     * Create new splash screen controller.
     */
    public function __construct()
    {
        $this->middleware( 'guest' );
    }

    /**
     * Show the application splash screen to the user.
     *
     * @return Response
     */
    public function index()
    {
        return view( 'splash' );
    }

    /**
     * Handles OAuth login redirects.
     *
     * @param $provider
     *
     * @return \Symfony\Component\HttpFoundation\RedirectResponse
     * @throws \DreamFactory\Rave\Exceptions\ForbiddenException
     * @throws \DreamFactory\Rave\Exceptions\NotFoundException
     */
    public function handleOAuthLogin( $provider )
    {
        /** @var BaseOAuthService $service */
        $service = ServiceHandler::getService( $provider );

        /** @var Provider $driver */
        $driver = $service->getDriver();

        return $driver->redirect();
    }

    /**
     * Performs ldap login
     *
     * @param $provider
     *
     * @return $this|\Illuminate\Http\RedirectResponse
     * @throws \DreamFactory\Rave\Exceptions\BadRequestException
     * @throws \DreamFactory\Rave\Exceptions\ForbiddenException
     * @throws \DreamFactory\Rave\Exceptions\NotFoundException
     * @throws \Exception
     */
    public static function handleADLdapLogin( $provider )
    {
        $username = \Request::input( 'email' );
        $password = \Request::input( 'password' );

        if ( !empty( $username ) && !empty( $password ) )
        {
            /** @var LdapService $service */
            $service = ServiceHandler::getService( $provider );

            /** @var ADLdapProvider $driver */
            $driver = $service->getDriver();

            $auth = $driver->authenticate( $username, $password );

            if ( $auth )
            {
                $ldapUser = $driver->getUser();

                $user = DspUser::createShadowADLdapUser( $ldapUser, $service );
                $user->update( [ 'last_login_date' => Carbon::now()->toDateTimeString() ] );

                \Auth::login( $user, \Request::has( 'remember' ) );

                return redirect()->intended( '/launchpad' );
            }
        }

        return redirect( '/auth/login' )->withInput( \Request::only( 'email', 'remember' ) )->withErrors(
                [
                    'email' => 'Invalid username and password.',
                ]
            );

    }

    /**
     * Handles OAuth callback from the provider after
     * successful authentication.
     *
     * @param string $serviceName
     *
     * @return array|\Illuminate\Http\RedirectResponse
     * @throws \DreamFactory\Rave\Exceptions\ForbiddenException
     * @throws \DreamFactory\Rave\Exceptions\NotFoundException
     * @throws \Exception
     */
    public function handleOAuthCallback( $serviceName )
    {
        /** @var BaseOAuthService $service */
        $service = ServiceHandler::getService( $serviceName );

        /** @var Provider $driver */
        $driver = $service->getDriver();

        /** @var User $user */
        $user = $driver->user();

        $dspUser = DspUser::createShadowOAuthUser( $user, $service );
        $dspUser->update( [ 'last_login_date' => Carbon::now()->toDateTimeString() ] );

        \Auth::login( $dspUser );

        if ( \Request::ajax() )
        {
            return [ 'success' => true, 'session_id' => \Session::getId() ];
        }
        else
        {
            return redirect()->intended( '/launchpad' );
        }
    }
}