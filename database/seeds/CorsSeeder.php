<?php

use DreamFactory\Core\Models\CorsConfig;

class CorsSeeder extends BaseModelSeeder
{
    protected $modelClass = CorsConfig::class;

    protected function getRecords()
    {
        return [
            [
                'path'                 => 'api/v2/system/admin/session',
                'description'          => 'integrateio sso',
                'origin'               => 'https://wewillchangethis.com',
                'header'               => '*',
                'exposed_header'       => null,
                'max_age'              => 0,
                "method"                => ["POST"],
                'supports_credentials' => false,
                'enabled'              => 'true'
            ],
        ];
    }
}
