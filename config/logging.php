<?php

use Monolog\Handler\StreamHandler;

return [

    /*
    |--------------------------------------------------------------------------
    | Default Log Channel
    |--------------------------------------------------------------------------
    |
    | This option defines the default log channel that gets used when writing
    | messages to the logs. The name specified in this option should match
    | one of the channels defined in the "channels" configuration array.
    |
    */

    'default'   => env('LOG_CHANNEL', env('APP_LOG', 'stack')),
    'log'       => env('LOG_CHANNEL', env('APP_LOG', 'stack')),
    'log_level' => env('APP_LOG_LEVEL', 'warning'),

    /*
    |--------------------------------------------------------------------------
    | Log Channels
    |--------------------------------------------------------------------------
    |
    | Here you may configure the log channels for your application. Out of
    | the box, Laravel uses the Monolog PHP logging library. This gives
    | you a variety of powerful log handlers / formatters to utilize.
    |
    | Available Drivers: "single", "daily", "slack", "syslog",
    |                    "errorlog", "monolog",
    |                    "custom", "stack"
    |
    */

    'channels' => [
        'stack' => [
            'driver' => 'stack',
            'channels' => ['single'],
        ],

        'single' => [
            'driver' => 'single',
            'path' => storage_path('logs/dreamfactory.log'),
            'level' => env('APP_LOG_LEVEL', 'warning'),
            'formatter' => Monolog\Formatter\LineFormatter::class,
            'formatter_with' => [
                'format' => null,
                'dateFormat' => null,
                'allowInlineLineBreaks' => true,
                'ignoreEmptyContextAndExtra' => true,
            ],
        ],

        'daily' => [
            'driver' => 'daily',
            'path' => storage_path('logs/dreamfactory.log'),
            'level' => env('APP_LOG_LEVEL', 'warning'),
            'days' => env('APP_LOG_MAX_FILES', 5),
            'formatter' => Monolog\Formatter\LineFormatter::class,
            'formatter_with' => [
                'format' => null,
                'dateFormat' => null,
                'allowInlineLineBreaks' => true,
                'ignoreEmptyContextAndExtra' => true,
            ],
        ],

        'slack' => [
            'driver' => 'slack',
            'url' => env('LOG_SLACK_WEBHOOK_URL'),
            'username' => 'Laravel Log',
            'emoji' => ':boom:',
            'level' => 'critical',
            'formatter' => Monolog\Formatter\LineFormatter::class,
            'formatter_with' => [
                'format' => null,
                'dateFormat' => null,
                'allowInlineLineBreaks' => true,
                'ignoreEmptyContextAndExtra' => true,
            ],
        ],

        'stderr' => [
            'driver' => 'monolog',
            'handler' => StreamHandler::class,
            'with' => [
                'stream' => 'php://stderr',
            ],
            'formatter' => Monolog\Formatter\LineFormatter::class,
            'formatter_with' => [
                'format' => null,
                'dateFormat' => null,
                'allowInlineLineBreaks' => true,
                'ignoreEmptyContextAndExtra' => true,
            ],
        ],

        'syslog' => [
            'driver' => 'syslog',
            'level' => env('APP_LOG_LEVEL', 'warning'),
            'formatter' => Monolog\Formatter\LineFormatter::class,
            'formatter_with' => [
                'format' => null,
                'dateFormat' => null,
                'allowInlineLineBreaks' => true,
                'ignoreEmptyContextAndExtra' => true,
            ],
        ],

        'errorlog' => [
            'driver' => 'errorlog',
            'level' => env('APP_LOG_LEVEL', 'warning'),
            'formatter' => Monolog\Formatter\LineFormatter::class,
            'formatter_with' => [
                'format' => null,
                'dateFormat' => null,
                'allowInlineLineBreaks' => true,
                'ignoreEmptyContextAndExtra' => true,
            ],
        ],
    ],

];
