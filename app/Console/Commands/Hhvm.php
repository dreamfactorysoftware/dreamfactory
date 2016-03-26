<?php

namespace DreamFactory\Console\Commands;

use Illuminate\Console\Command;

class Hhvm extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:hhvm 
                            {--port=8080 : Port number to run hhvm on.}
                            {--config-only : Use this option to create the config file only.}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generates config file for hhvm';

    /**
     * Create a new command instance.
     */
    public function __construct()
    {
        parent::__construct();
    }

    public function handle()
    {
        $file = 'hhvm.hdf';
        $port = $this->option('port');
        $serverRoot = base_path('public');

        $config = <<<config
Server {
  Port = $port
  SourceRoot = $serverRoot
}

VirtualHost {
 * {
   Pattern = .*
   RewriteRules {
      * {
        pattern = .?

	# app bootstrap
        to = index.php

        # append the original query string
        qsa = true
      }
   }
 }
}

StaticFile {
  Extensions {
    css = text/css
    gif = image/gif
    html = text/html
    jpe = image/jpeg
    jpeg = image/jpeg
    jpg = image/jpeg
    png = image/png
    tif = image/tiff
    tiff = image/tiff
    txt = text/plain
  }
}
config;
        file_put_contents($file, $config);
        $this->info('Generated config file '.$file);
        if(false === $this->option('config-only')) {
            $this->info('Starting hhvm on port ' . $port . ' ...');
            exec("hhvm -m server -c $file", $out);
        }
    }
}