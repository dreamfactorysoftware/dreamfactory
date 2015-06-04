<?php
/**
 * This file is part of the DreamFactory Rave(tm)
 *
 * DreamFactory Rave(tm) <http://github.com/dreamfactorysoftware/rave>
 * Copyright 2012-2014 DreamFactory Software, Inc. <support@dreamfactory.com>
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

return array(
    'db_max_records_returned' => 1000,
    'local_file_service_root' => storage_path()."/app",
    'local_file_service_root_test' => storage_path()."/test",
    /** The default number of records to return at once for database queries */
    'dsp.db_max_records_returned'   => 1000,
    //-------------------------------------------------------------------------
    //	Date and Time Format Options
    //  The default date and time formats used for in and out requests for
    //  all database services, including stored procedures and system service resources.
    //  Default values of null means no formatting is performed on date and time field values.
    //  For options see https://github.com/dreamfactorysoftware/dsp-core/wiki/Database-Date-Time-Formats
    //  Examples: 'm/d/y h:i:s A' or 'c' or DATE_COOKIE
    //-------------------------------------------------------------------------
    'dsp.db_time_format'            => null,
    'dsp.db_date_format'            => null,
    'dsp.db_datetime_format'        => null,
    'dsp.db_timestamp_format'       => null,
    /** Enable/disable detailed CORS logging */
    'dsp.log_cors_info'             => false,
    'default_cache_ttl'             => env('CACHE_TTL', 300),
    'cors' => array(
        'defaults' => array(
            'supportsCredentials' => false,
            'allowedOrigins' => array('*'),
            'allowedHeaders' => array(),
            'allowedMethods' => array(),
            'exposedHeaders' => array(),
            'maxAge' => 0,
            'hosts' => array(),
        )
    )
);