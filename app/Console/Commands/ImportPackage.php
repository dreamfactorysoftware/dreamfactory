<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Core\Utility\Packager;
use Illuminate\Console\Command;

class ImportPackage extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:import-pkg {path : Relative path to the package file}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Import resources from a DreamFactory package (dfpkg) or zip file.';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        //
        $path = $this->argument('path');
        $packager = new Packager($path);
        $packager->importAppFromPackage();
    }
}
