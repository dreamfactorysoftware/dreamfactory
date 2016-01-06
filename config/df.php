<?php

return [
    'version'                      => '2.0.4',
    // General API version number, 1.x was earlier product and may be supported by most services
    'api_version'                  => '2.0',
    // Name of this DreamFactory instance. Defaults to server name.
    'instance_name'                => env('DF_INSTANCE_NAME', gethostname()),
    // XML root tag for http request and response.
    'xml_request_root'             => 'dfapi',
    'xml_response_root'            => 'dfapi',
    // Most API calls return a resource array or a single resource, if array, do we wrap it?
    'always_wrap_resources'        => true,
    'resources_wrapper'            => 'resource',
    // Default content-type of response when accepts header is missing or empty.
    'default_response_type'        => 'application/json',
    // Local File Storage setup, see also local config/filesystems.php
    'storage_path'                 => env('DF_MANAGED_STORAGE_PATH', storage_path()),
    'local_file_service_container' => trim(env('DF_LOCAL_FILE_ROOT', 'app'), '/'),
    // DB configs
    'db'                           => [
        // The default number of records to return at once for database queries
        'max_records_returned' => env('DF_DB_MAX_RECORDS_RETURNED', 1000),
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
        'sqlite_storage'       => env('DF_SQLITE_STORAGE',
            rtrim(env('DF_MANAGED_STORAGE_PATH', storage_path()), '/') . '/databases/'),
        // FreeTDS configuration (Linux and OS X only)
        'freetds'              => [
            // DB connection types, these dictate the TDS version and other config
            // Location of SQL Server conf file, defaults to server/config/freetds/sqlsrv.conf
            'sqlsrv'      => env('DF_FREETDS_SQLSRV', base_path('server/config/freetds/sqlsrv.conf')),
            // Location of SAP/Sybase conf file, defaults to server/config/freetds/sqlanywhere.conf
            'sqlanywhere' => env('DF_FREETDS_SQLANYWHERE', base_path('server/config/freetds/sqlanywhere.conf')),
            // Location of old Sybase conf file, defaults to server/config/freetds/sybase.conf
            'sybase'      => env('DF_FREETDS_SYBASE', base_path('server/config/freetds/sybase.conf')),
            // Enabling and location of dump file, defaults to disabled or default freetds.conf setting
            'dump'        => env('DF_FREETDS_DUMP'),
            // Location of connection dump file, defaults to disabled
            'dumpconfig'  => env('DF_FREETDS_DUMPCONFIG'),
        ],
    ],
    // Cache config, in minutes
    'default_cache_ttl'            => env('DF_CACHE_TTL', 300),
    // Session config
    'allow_forever_sessions'       => env('DF_ALLOW_FOREVER_SESSIONS', false),
    // System URLs
    'confirm_reset_url'            => env('DF_CONFIRM_RESET_URL', '/dreamfactory/dist/#/reset-password'),
    'confirm_invite_url'           => env('DF_CONFIRM_INVITE_URL', '/dreamfactory/dist/#/user-invite'),
    'confirm_register_url'         => env('DF_CONFIRM_REGISTER_URL', '/dreamfactory/dist/#/register-confirm'),
    'landing_page'                 => env('DF_LANDING_PAGE', '/dreamfactory/dist/index.html'),
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
        ],
    ],
    'scripting'                    => [
        // 'all' to disable all scripting, or comma-delimited list of v8js, nodejs, and/or php
        'disable'     => env('DF_SCRIPTING_DISABLE'),
        // path to the installed nodejs executable
        'nodejs_path' => env('DF_NODEJS_PATH'),
    ],
];
