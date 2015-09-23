<?php namespace DreamFactory\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{

    /**
     * The Artisan commands provided by your application.
     *
     * @var array
     */
    protected $commands = [
//        'DreamFactory\Console\Commands\Inspire',
        'DreamFactory\Console\Commands\ClearAllFileCache',
        'DreamFactory\Console\Commands\Request',
        'DreamFactory\Console\Commands\Import',
        'DreamFactory\Console\Commands\ImportPackage',
        'DreamFactory\Console\Commands\PullMigrations',
    ];

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule $schedule
     *
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
//        $schedule->command('inspire')->hourly();
    }
}
