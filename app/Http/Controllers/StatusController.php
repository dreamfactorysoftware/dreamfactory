<?php

namespace DreamFactory\Http\Controllers;

use DreamFactory\Core\Exceptions\InternalServerErrorException;
use DreamFactory\Core\Models\App;
use DreamFactory\Core\Models\AppGroup;
use DreamFactory\Core\Models\Role;
use DreamFactory\Core\Models\Service;
use DreamFactory\Core\Models\User;
use DreamFactory\Core\Resources\System\Environment;
use DreamFactory\Core\Utility\ResponseFactory;

class StatusController extends Controller
{
    public static function getURI($s)
    {
        $ssl = (!empty($s['HTTPS']) && $s['HTTPS'] == 'on');
        $sp = strtolower($s['SERVER_PROTOCOL']);
        $protocol = substr($sp, 0, strpos($sp, '/')) . (($ssl) ? 's' : '');
        $port = $s['SERVER_PORT'];
        $port = ((!$ssl && $port == '80') || ($ssl && $port == '443')) ? '' : ':' . $port;
        $host = (isset($s['HTTP_HOST']) ? $s['HTTP_HOST'] : $s['SERVER_NAME']);

        return $protocol . '://' . $host . $port;
    }

    public function index()
    {
        $uri = static::getURI($_SERVER);

        $dist = env('DF_INSTALL', '');
        if (empty($dist) && (false !== stripos(env('DB_DATABASE', ''), 'bitnami'))) {
            $dist = 'Bitnami';
        }

        $appCount = App::all()->count();
        $appGroupCount = AppGroup::all()->count();
        $adminCount = User::whereIsSysAdmin(1)->count();
        $userCount = User::whereIsSysAdmin(0)->count();
        $serviceCount = Service::all()->count();
        $roleCount = Role::all()->count();

        $status = [
            "uri"       => $uri,
            "managed"   => env('DF_MANAGED', false),
            "dist"      => $dist,
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