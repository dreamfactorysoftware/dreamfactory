<?php

/*
|--------------------------------------------------------------------------
| Create The Application
|--------------------------------------------------------------------------
|
| The first thing we will do is create a new Laravel application instance
| which serves as the "glue" for all the components of Laravel, and is
| the IoC container for the system binding all of the various parts.
|
*/

use DreamFactory\Managed\Support\Managed;
use Monolog\Handler\StreamHandler;
use Monolog\Formatter\LineFormatter;
use Monolog\Handler\SyslogHandler;
use Monolog\Handler\ErrorLogHandler;
use Monolog\Handler\RotatingFileHandler;

$app = new Illuminate\Foundation\Application(
    realpath(__DIR__ . '/../')
);

/*
|--------------------------------------------------------------------------
| Bind Important Interfaces
|--------------------------------------------------------------------------
|
| Next, we need to bind some important interfaces into the container so
| we will be able to resolve them when needed. The kernels serve the
| incoming requests to this application from both the web and CLI.
|
*/

$app->singleton(
    'Illuminate\Contracts\Http\Kernel',
    'DreamFactory\Http\Kernel'
);

$app->singleton(
    'Illuminate\Contracts\Console\Kernel',
    'DreamFactory\Console\Kernel'
);

$app->singleton(
    'Illuminate\Contracts\Debug\ExceptionHandler',
    'DreamFactory\Exceptions\Handler'
);

$app->configureMonologUsing(function ($monolog){
    $logFile = storage_path('logs/dreamfactory.log');
    if (!config('df.standalone')) {
        $logFile = Managed::getLogFile();
    }

    $mode = config('app.log');

    if ($mode === 'syslog') {
        $monolog->pushHandler(new SyslogHandler('dreamfactory'));
    } else {
        if ($mode === 'single') {
            $handler = new StreamHandler($logFile);
        } else if ($mode === 'errorlog') {
            $handler = new ErrorLogHandler();
        } else {
            $handler = new RotatingFileHandler($logFile, 5);
        }

        $monolog->pushHandler($handler);
        $handler->setFormatter(new LineFormatter(null, null, true, true));
    }
});

/*
|--------------------------------------------------------------------------
| Return The Application
|--------------------------------------------------------------------------
|
| This script returns the application instance. The instance is given to
| the calling script so we can separate the building of the instances
| from the actual running of the application and sending responses.
|
*/

return $app;
