<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Managed\Support\Managed;
use Illuminate\Console\Command;

class ClearAllFileCache extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:clear-file-cache';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command to clear all DreamFactory file-based cache, locally or in hosted environment.';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();

        if (config('df.standalone')) {
            $this->cacheRoot = storage_path('framework/cache');
        } else {
            $this->cacheRoot = Managed::getCacheRoot();
        }
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $this->laravel['events']->fire('cache:clearing', ['file']);
        $this->removeDirectory($this->cacheRoot);
        $this->laravel['events']->fire('cache:cleared', ['file']);
        $this->info('Cleared DreamFactory cache for all instances!');
    }

    /**
     * Removes directories recursively.
     *
     * @param $path
     */
    protected function removeDirectory($path)
    {
        $files = glob($path . '/*');
        foreach ($files as $file) {
            if (is_dir($file)) {
                static::removeDirectory($file);
            } else if (basename($file) !== '.gitignore') {
                unlink($file);
            }
        }
        if ($path !== $this->cacheRoot) {
            rmdir($path);
        }

        return;
    }
}
