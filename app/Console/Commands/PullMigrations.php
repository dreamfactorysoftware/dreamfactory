<?php

namespace DreamFactory\Console\Commands;

use Illuminate\Console\Command;

class PullMigrations extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:pull-migrations
    {--src=vendor : Top directory to search from}
    {--dst=database/migrations : Which directory to place migrations found}
    {--search=database/migrations : Path to search in each sub-directory}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command to pull migrations from composer libraries to application migrations directory.';

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
        // Next, we will check to see if the source path option has been defined. If it has
        // we will use the path relative to the root of this installation folder
        // so that migrations may be pulled from any sub directory.
        if (! is_null($path = $this->option('src'))) {
            $source = $this->laravel->basePath().'/'.rtrim($path, '/') . '/';
        } else {
            $source = $this->laravel->basePath().'/vendor/';
        }

        // Next, we will check to see if the destination path option has been defined. If it has
        // we will use the path relative to the root of this installation folder
        // to place the migrations we find.
        if (! is_null($path = $this->option('dst'))) {
            $destination = $this->laravel->basePath().'/'.rtrim($path, '/') . '/';
        } else {
            $destination = $this->laravel->basePath().'/database/migrations/';
        }

        // Next, we will check to see if a search path option has been defined. If it has
        // we will use the path relative to each searched path to check for migrations.
        if (! is_null($path = $this->option('search'))) {
            $search = '/'.trim($path, '/'). '/';
        } else {
            $search = '/database/migrations/';
        }

        $vendors = new \DirectoryIterator($source);
        foreach ($vendors as $vendor) {
            if (!$vendor->isDot() && $vendor->isDir()) {
                $products = new \DirectoryIterator($source . $vendor);
                foreach ($products as $product) {
                    if (!$product->isDot() && $product->isDir()) {
                        $potential = $product->getRealPath() . $search;
                        if (is_dir($potential)) {
                            $this->rcopy($potential, $destination);
                        }
                    }
                }
            }
        }
        $this->info("Finished pulling migrations from $source to $destination.");
    }

    protected function rcopy($src, $dst)
    {
        // If source is not a directory stop processing
        if (!is_dir($src)) {
            return false;
        }

        // If the destination directory does not exist create it
        if (!is_dir($dst)) {
            if (!mkdir($dst)) {
                // If the destination directory could not be created stop processing
                return false;
            }
        }

        // Open the source directory to read in files
        $i = new \DirectoryIterator($src);
        foreach ($i as $f) {
            if ($f->isFile()) {
                $this->info('Copying '.$f->getFilename().' from '.$f->getPath());
                copy($f->getRealPath(), $dst . $f->getFilename());
            } else if (!$f->isDot() && $f->isDir()) {
                rcopy($f->getRealPath(), $dst.$f);
            }
        }

        return true;
    }
}
