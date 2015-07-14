<?php

namespace Dreamfactory\Http\Middleware;

use Closure;
use DreamFactory\Core\Exceptions\InternalServerErrorException;
use DreamFactory\Core\Exceptions\TooManyRequestsException;
use DreamFactory\Core\Utility\ResponseFactory;
use DreamFactory\Core\Utility\Session;
use Illuminate\Contracts\Routing\Middleware;

class Limits
{

    private $_inUnitTest = false;

    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request $request
     * @param  \Closure                 $next
     *
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        // Get limits
        $limits = Enterprise::getPolicyLimits();

        if (is_null($limits) === false) {

            $this->_inUnitTest = \Config::get('api_limits_test');

            list($userName, $userRole) = $this->_getUserAndRole();

            $apiName = $this->_getApiKey();

            $serviceName = $this->_getServiceName();

            // Build the list of API Hits to check

            $apiKeysToCheck = array('default' => 0);

            if (empty($userRole) === false) {
                $apiKeysToCheck[$userRole] = 0;
            }

            if (empty($userName) === false) {
                $apiKeysToCheck[$userName] = 0;
            }

            if (empty($serviceName) === false) {
                $apiKeysToCheck[$serviceName] = 0;

                if (empty($userRole) === false) {
                    $apiKeysToCheck[$serviceName . '.' . $userRole] = 0;
                }

                if (empty($userName) === false) {
                    $apiKeysToCheck[$serviceName . '.' . $userName] = 0;
                }
            }

            if (empty($apiName) === false) {
                $apiKeysToCheck[$apiName] = 0;

                if (empty($userRole) === false) {
                    $apiKeysToCheck[$apiName . '.' . $userRole] = 0;
                }

                if (empty($userName) === false) {
                    $apiKeysToCheck[$apiName . "." . $userName] = 0;
                }

                if (empty($serviceName) === false) {
                    $apiKeysToCheck[$apiName . "." . $serviceName] = 0;

                    if (empty($userRole) === false) {
                        $apiKeysToCheck[$apiName . "." . $serviceName . '.' . $userRole] = 0;
                    }

                    if (empty($userName) === false) {
                        $apiKeysToCheck[$apiName . "." . $serviceName . '.' . $userName] = 0;
                    }
                }
            }

            $overLimit = false;
            try {
                foreach ($limits['api'] as $key => $limit) {
                    if (array_key_exists($key, $apiKeysToCheck) === true) {

                        $cacheValue = \Cache::get($key, 0);
                        $cacheValue++;
                        \Cache::put($key, $cacheValue, $limit['period']);
                        if ($cacheValue > $limit['limit']) {
                            $overLimit = true;
                        }
                    }
                }
            } catch (\Exception $e) {
                return ResponseFactory::getException(
                    new InternalServerErrorException('Unable to update cache'),
                    $request
                );
            }

            if ($overLimit === true) {
                return ResponseFactory::getException(
                    new TooManyRequestsException('Specified connection limit exceeded'),
                    $request
                );
            }
        }

        return $next($request);
    }

    /*
     * Stub to get User and Role name from the authentication session/cookie
     */

    private function _getUserAndRole()
    {
        if ($this->_inUnitTest === true) {
            return ['user_1', 'role_2'];
        } else {
            return [
                'user_' . Session::getCurrentUserId(),
                'role_' . Session::getRoleId()
            ];
        }
    }

    /*
     * Stub to get the API Key
     */

    private function _getApiKey()
    {
        if ($this->_inUnitTest === true) {
            return 'apiName';
        } else {
            return Session::getApiKey();
        }
    }

    /*
     * Stub to get the Service name
     */

    private function _getServiceName()
    {
        if ($this->_inUnitTest === true) {
            return 'serviceName';
        } else {
            /** @var Router $router */
            $router = app('router');
            $service = strtolower($router->input('service'));

            return $service;
        }
    }
}
