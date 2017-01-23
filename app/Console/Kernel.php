<?php namespace DreamFactory\Console;

use DreamFactory\Managed\Bootstrap\ManagedInstance;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /** @inheritdoc */
    protected $commands = [
        'DreamFactory\Console\Commands\ClearAllFileCache',
        'DreamFactory\Console\Commands\Request',
        'DreamFactory\Console\Commands\Import',
        'DreamFactory\Console\Commands\ImportPackage',
        'DreamFactory\Console\Commands\PullMigrations',
        'DreamFactory\Console\Commands\Setup',
        'DreamFactory\Console\Commands\ADGroupImport',
        'DreamFactory\Console\Commands\HomesteadConfig',
        'DreamFactory\Console\Commands\ServiceTypeMigrate',
    ];

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        // $schedule->command('inspire')
        //          ->hourly();
    }

    /**
     * Register the Closure based commands for the application.
     *
     * @return void
     */
    protected function commands()
    {
        require base_path('routes/console.php');
    }

    /**
     * Inject our bootstrapper into the mix
     */
    protected function bootstrappers()
    {
        $_stack = parent::bootstrappers();

        //  Insert our guy
        array_unshift($_stack, array_shift($_stack), ManagedInstance::class);

        return $_stack;
    }
}
