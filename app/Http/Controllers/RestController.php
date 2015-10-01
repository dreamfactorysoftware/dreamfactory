<?php
namespace DreamFactory\Http\Controllers;

use Request;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException;
use DreamFactory\Library\Utility\Enums\Verbs;
use DreamFactory\Core\Utility\ResponseFactory;
use DreamFactory\Core\Utility\ServiceHandler;
use DreamFactory\Core\Contracts\ServiceResponseInterface;

/**
 * Class RestController
 *
 * @package DreamFactory\Core\Http\Controllers
 */
class RestController extends Controller
{

    /**
     * Create new Rest Controller.
     */
    public function __construct()
    {
        $this->middleware('access_check');
        $this->middleware('api_limits');
    }

    /**
     * Handles the root (/) path
     *
     * @param null|string $version
     *
     * @return null|ServiceResponseInterface
     */
    public function index(
        /** @noinspection PhpUnusedParameterInspection */
        $version = null
    ){
        try {
            $services = ServiceHandler::listServices();
            $response = ResponseFactory::create($services);
        } catch (\Exception $e) {
            $response = ResponseFactory::create($e);
        }

        return ResponseFactory::sendResponse($response);
    }

    /**
     * Handles the GET requests
     *
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handleV1GET($service = null, $resource = null)
    {
        return $this->handleGET('v1', $service, $resource);
    }

    /**
     * Handles the POST requests
     *
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handleV1POST($service = null, $resource = null)
    {
        return $this->handlePOST('v1', $service, $resource);
    }

    /**
     * Handles the PUT requests
     *
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handleV1PUT($service = null, $resource = null)
    {
        return $this->handlePUT('v1', $service, $resource);
    }

    /**
     * Handles the PATCH requests
     *
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handleV1PATCH($service = null, $resource = null)
    {
        return $this->handlePATCH('v1', $service, $resource);
    }

    /**
     * Handles DELETE requests
     *
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handleV1DELETE($service = null, $resource = null)
    {
        return $this->handleDELETE('v1', $service, $resource);
    }

    /**
     * Handles the GET requests
     *
     * @param null|string $version
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handleGET($version = null, $service = null, $resource = null)
    {
        return $this->handleService($version, $service, $resource);
    }

    /**
     * Handles the POST requests
     *
     * @param null|string $version
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handlePOST($version = null, $service = null, $resource = null)
    {
        // Check for the various method override headers or query params
        $xMethod =
            Request::header('X-HTTP-Method',
                Request::header('X-HTTP-Method-Override',
                    Request::header('X-Method-Override', Request::query('method'))));;
        if (!empty($xMethod)) {
            if (!in_array($xMethod, Verbs::getDefinedConstants())) {
                throw new MethodNotAllowedHttpException("Invalid verb tunneling with " . $xMethod);
            }
            Request::setMethod($xMethod);
        }

        return $this->handleService($version, $service, $resource);
    }

    /**
     * Handles the PUT requests
     *
     * @param null|string $version
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handlePUT($version = null, $service = null, $resource = null)
    {
        return $this->handleService($version, $service, $resource);
    }

    /**
     * Handles the PATCH requests
     *
     * @param null|string $version
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handlePATCH($version = null, $service = null, $resource = null)
    {
        return $this->handleService($version, $service, $resource);
    }

    /**
     * Handles DELETE requests
     *
     * @param null|string $version
     * @param null|string $service
     * @param null|string $resource
     *
     * @return null|ServiceResponseInterface
     */
    public function handleDELETE($version = null, $service = null, $resource = null)
    {
        return $this->handleService($version, $service, $resource);
    }

    /**
     * Handles all service requests
     *
     * @param null|string $version
     * @param string      $service
     * @param null|string $resource
     *
     * @return ServiceResponseInterface|null
     */
    public function handleService($version = null, $service, $resource = null)
    {
        try {
            $service = strtolower($service);

            // fix removal of trailing slashes from resource
            if (!empty($resource)) {
                $uri = \Request::getRequestUri();
                if ((false === strpos($uri, '?') && '/' === substr($uri, strlen($uri) - 1, 1)) ||
                    ('/' === substr($uri, strpos($uri, '?') - 1, 1))
                ) {
                    $resource .= '/';
                }
            }

            $response = ServiceHandler::processRequest($version, $service, $resource);
        } catch (\Exception $e) {
            $response = ResponseFactory::create($e);
        }

        if ($response instanceof RedirectResponse) {
            return $response;
        }

        return ResponseFactory::sendResponse($response, null, null, $resource);
    }
}