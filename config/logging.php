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
