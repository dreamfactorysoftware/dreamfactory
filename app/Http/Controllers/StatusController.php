<?php

namespace DreamFactory\Http\Controllers;

use DreamFactory\Core\Models\App;
use DreamFactory\Core\Models\AppGroup;
use DreamFactory\Core\Models\Role;
use DreamFactory\Core\Models\Service;
use DreamFactory\Core\Models\User;
use DreamFactory\Core\Resources\System\Environment;
use DreamFactory\Core\Utility\ResponseFactory;

class StatusController extends Controller
{
    public function index()
    {
        $appCount = App::all()->count();
        $appGroupCount = AppGroup::all()->count();
        $adminCount = User::whereIsSysAdmin(1)->count();
        $userCount = User::whereIsSysAdmin(0)->count();
        $serviceCount = Service::all()->count();
        $roleCount = Role::all()->count();

        $status = [
            "uri"       => ($_SERVER['SERVER_NAME'])? $_SERVER['SERVER_NAME'] : $_SERVER['HTTP_HOST'],
            "managed"   => env('DF_MANAGED', false),
            "dist"      => env('DF_INSTALL', ''),
            "demo"      => Environment::isDemoApplication(),
            "version"   => \Config::get('df.version'),
            "host_os"   => PHP_OS,
            "resources" => [
                "app"       => $appCount,
                "app_group" => $appGroupCount,
                "admin"     => $adminCount,
                "user"      => $userCount,
                "service"   => $serviceCount,
                "role"      => $roleCount
            ]
        ];

        return ResponseFactory::sendResponse(ResponseFactory::create($status));
    }
}