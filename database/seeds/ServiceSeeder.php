<?php

use DreamFactory\Core\Models\Service;

class ServiceSeeder extends BaseModelSeeder
{
    protected $modelClass = Service::class;

    protected $records = [
        [
            'name'        => 'system',
            'label'       => 'System Management',
            'description' => 'Service for managing system resources.',
            'is_active'   => true,
            'type'        => 'system',
            'mutable'     => false,
            'deletable'   => false
        ],
//        [
//            'name'        => 'api_docs',
//            'label'       => 'Live API Docs',
//            'description' => 'API documenting and testing service.',
//            'is_active'   => true,
//            'type'        => 'swagger',
//            'mutable'     => false,
//            'deletable'   => false
//        ],
//        [
//            'name'        => 'files',
//            'label'       => 'Local File Storage',
//            'description' => 'Service for accessing local file storage.',
//            'is_active'   => true,
//            'type'        => 'local_file',
//            'mutable'     => true,
//            'deletable'   => true
//        ],
//        [
//            'name'        => 'logs',
//            'label'       => 'Local Log Storage',
//            'description' => 'Service for accessing local log storage.',
//            'is_active'   => true,
//            'type'        => 'local_file',
//            'mutable'     => true,
//            'deletable'   => true,
//            'config'      => ['container' => 'logs']
//        ],
//        [
//            'name'        => 'db',
//            'label'       => 'Local SQL Database',
//            'description' => 'Service for accessing local SQLite database.',
//            'is_active'   => true,
//            'type'        => 'sqlite',
//            'mutable'     => true,
//            'deletable'   => true,
//            'config'      => ['database' => 'db.sqlite']
//        ],
//        [
//            'name'        => 'email',
//            'label'       => 'Local Email Service',
//            'description' => 'Email service used for sending user invites and/or password reset confirmation.',
//            'is_active'   => true,
//            'type'        => 'local_email',
//            'mutable'     => true,
//            'deletable'   => true
//        ],
    ];
}
