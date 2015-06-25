<?php

return [
    /** General API version number, 1.x was earlier product and may be supported by most services */
    'api_version'                  => '2.0',
    /** Local File Storage setup, see also local config/filesystems.php */
    'local_file_service_root'      => storage_path() . "/app",
    'local_file_service_root_test' => storage_path() . "/test",
    'db'                           => [
        /** The default number of records to return at once for database queries */
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
    ],
    /** Enable/disable detailed CORS logging */
    'log_cors_info'                => false,
    'default_cache_ttl'            => env('CACHE_TTL', 300),
    'allow_forever_sessions'       => true,
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