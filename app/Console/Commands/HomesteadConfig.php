<?php

namespace DreamFactory\Console\Commands;

use Illuminate\Console\Command;

class HomesteadConfig extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:homestead-config';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Create a new command instance.
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
        if(file_exists('vendor/bin/homestead')){
            exec('php vendor/bin/homestead make', $out);
            $output = implode('\n', $out);
            $this->info($output);
        }
    }
}
