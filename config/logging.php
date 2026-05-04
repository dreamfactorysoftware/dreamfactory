<?php

use Monolog\Handler\StreamHandler;

return [

    'log' => env('LOG_CHANNEL', env('APP_LOG', 'stack')),

    'log_level' => env('APP_LOG_LEVEL', 'warning'),

    'channels' => [
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
            'replace_placeholders' => true,
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
            'replace_placeholders' => true,
        ],

        'heroku' => [
            'driver' => 'errorlog',
            'level' => env('APP_LOG_LEVEL', 'debug'),
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
            'replace_placeholders' => true,
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
            'level' => env('LOG_LEVEL', 'debug'),
                'stream' => 'php://stderr',
            'processors' => [PsrLogMessageProcessor::class],
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
            'facility' => env('LOG_SYSLOG_FACILITY', LOG_USER),
            'replace_placeholders' => true,
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
            'replace_placeholders' => true,
        ],
    ],

];
