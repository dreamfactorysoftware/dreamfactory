<?php

namespace DreamFactory\Http\Controllers;

use Illuminate\Http\JsonResponse;

class SystemController extends Controller
{
    public function getEnvironment()
    {
        return new JsonResponse([
            'platform' => [
                'version' => config('app.version'),
                'is_hosted' => false,
                'license' => []
            ],
            'server' => [
                'php_version' => PHP_VERSION,
                'os' => PHP_OS
            ]
        ]);
    }
} 