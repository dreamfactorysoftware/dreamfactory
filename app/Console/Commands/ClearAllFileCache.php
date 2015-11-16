<?php
namespace DreamFactory\Console\Commands;

use Illuminate\Console\Command;

class ClearAllFileCache extends Command
{
    /** @inheritdoc */
    protected $signature = 'dreamfactory:clear-file-cache';

    /** @inheritdoc */
    protected $description = 'Command to clear all DreamFactory file-based cache, locally or in hosted environment.';

    /** @inheritdoc */
    public function __construct()
    {
        parent::__construct();

        $this->cacheRoot = config('cache.path', storage_path('framework/cache'));
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
