<?php
namespace DreamFactory\Http\Controllers;

use DreamFactory\Core\Exceptions\ForbiddenException;
use DreamFactory\Core\Services\BaseFileService;
use DreamFactory\Core\Components\DfResponse;
use ServiceManager;
use Symfony\Component\HttpFoundation\StreamedResponse;

class StorageController extends Controller
{
    public function handleGET($storage, $path)
    {
        try {
            \Log::info('[REQUEST] Storage', [
                'Method'  => 'GET',
                'Service' => $storage,
                'Path'    => $path
            ]);

            $storage = strtolower($storage);

            /** @type BaseFileService $service */
            $service = ServiceManager::getService($storage);

            //Check for private paths here.
            $publicPaths = $service->publicPaths;

            //Clean trailing slashes from paths
            array_walk($publicPaths, function (&$value){
                $value = rtrim($value, '/');
            });

            $directory = rtrim(substr($path, 0, strlen(substr($path, 0, strrpos($path, '/')))), '/');
            $pieces = explode("/", $directory);
            $dir = null;
            $allowed = false;

            foreach ($pieces as $p) {
                if (empty($dir)) {
                    $dir = $p;
                } else {
                    $dir .= "/" . $p;
                }

                if (in_array($dir, $publicPaths)) {
                    $allowed = true;
                    break;
                }
            }

            if ($allowed) {
                \Log::info('[RESPONSE] File stream');

                $response = new StreamedResponse();
                $response->setCallback(function () use ($service, $path){
                    $service->streamFile($service->getContainerId(), $path);
                });

                return $response;
            } else {
                throw new ForbiddenException('You do not have access to requested file.');
            }
        } catch (\Exception $e) {
            $content = $e->getMessage();
            $status = $e->getCode();
            $contentType = 'text/html';
            \Log::info('[RESPONSE]', ['Status Code' => $status, 'Content-Type' => $contentType]);

            return DfResponse::create($content, $status, ["Content-Type" => $contentType]);
        }
    }
}