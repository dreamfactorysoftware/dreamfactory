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
                $container = substr($path, 0, strpos($path, '/'));
                $path = ltrim(substr($path, strpos($path, '/') + 1), '/');
                $service->streamFile($container, $path);
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