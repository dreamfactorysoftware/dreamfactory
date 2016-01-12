<?php namespace DreamFactory\Console;

use DreamFactory\Managed\Bootstrap\ManagedInstance;
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
    ];

    //******************************************************************************
    //* Methods
    //******************************************************************************

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
