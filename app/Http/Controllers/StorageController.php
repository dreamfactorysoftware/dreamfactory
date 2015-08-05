<?php
namespace DreamFactory\Http\Controllers;

use DreamFactory\Core\Exceptions\ForbiddenException;
use DreamFactory\Core\Utility\ServiceHandler;
use DreamFactory\Core\Services\BaseFileService;
use DreamFactory\Core\Components\DfResponse;

class StorageController extends Controller
{
    public function handleGET($storage, $path)
    {
        try {
            $storage = strtolower($storage);

            /** @type BaseFileService $service */
            $service = ServiceHandler::getService($storage);

            //Check for private paths here.
            $publicPaths = $service->publicPaths;

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
                $service->streamFile(null, $path);
            } else {
                throw new ForbiddenException('You do not have access to requested file.');
            }
        } catch (\Exception $e) {
            $content = $e->getMessage();
            $status = $e->getCode();
            $contentType = 'text/html';

            return DfResponse::create($content, $status, ["Content-Type" => $contentType]);
        }
    }
}