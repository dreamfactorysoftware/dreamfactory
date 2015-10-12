<?php

return [
    // Name of this DreamFactory instance. Defaults to server name.
    'instance_name'                => env('DF_INSTANCE_NAME', gethostname()),

    // XML root tag for http request and response.
    'xml_request_root'             => 'dfapi',
    'xml_response_root'            => 'dfapi',

    // General API version number, 1.x was earlier product and may be supported by most services
    'api_version'                  => '2.0',

    // Most API calls return a resource array or a single resource, if array, do we wrap it?
    'always_wrap_resources'        => true,
    'resources_wrapper'            => 'resource',

    // Default content-type of response when accepts header is missing or empty.
    'default_response_type'        => 'application/json',

    // Local File Storage setup, see also local config/filesystems.php
    'storage_path'                 => storage_path(),
    'local_file_service_container' => '/' . ltrim(env('DF_LOCAL_FILE_ROOT', '/app'), '/'),

    // Set this false for hosted/managed environment.
    'standalone'                   => env('DF_STANDALONE', true),

    // DB configs
    'db'                           => [
        // The default number of records to return at once for database queries
        'max_records_returned' => 1000,
        //-------------------------------------------------------------------------
        //	Date and Time Format Options
        //  The default date and time formats used for in and out requests for
        //  all database services, including stored procedures and system service resources.
        //  Default values of null means no formatting is performed on date and time field values.
        //  For options see https://github.com/dreamfactorysoftware/dsp-core/wiki/Database-Date-Time-Formats
        //  Examples: 'm/d/y h:i:s A' or 'c' or DATE_COOKIE
        //-------------------------------------------------------------------------
        'time_format'          => null,
        'date_format'          => null,
        'datetime_format'      => null,
        'timestamp_format'     => null,
        // Default location to store SQLite3 database files
        'sqlite_storage'       => env('DF_SQLITE_STORAGE', storage_path() . '/databases/'),
    ],

    // Cache / Session config
    'default_cache_ttl'            => env('DF_CACHE_TTL', 300),
    'allow_forever_sessions'       => false,

    // System URLs
    'confirm_reset_url'            => env('DF_CONFIRM_RESET_URL', '/dreamfactory/dist/#/reset-password'),
    'confirm_invite_url'           => env('DF_CONFIRM_INVITE_URL', '/dreamfactory/dist/#/user-invite'),
    'confirm_register_url'         => env('DF_CONFIRM_REGISTER_URL', '/dreamfactory/dist/#/register-confirm'),
    'landing_page'                 => env('DF_LANDING_PAGE', '/dreamfactory/dist'),

    // Enable/disable detailed CORS logging
    'log_cors_info'                => false,

    // Default CORS setting
    'cors'                         => [
        'defaults' => [
            'supportsCredentials' => false,
            'allowedOrigins'      => ['*'],
            'allowedHeaders'      => [],
            'allowedMethods'      => [],
            'exposedHeaders'      => [],
            'maxAge'              => 0,
            'hosts'               => [],
        ]
    ]
];
