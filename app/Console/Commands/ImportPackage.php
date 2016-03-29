<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Core\Components\Package\Importer;
use DreamFactory\Core\Components\Package\Package;
use DreamFactory\Core\Utility\FileUtilities;
use DreamFactory\Core\Utility\Packager;
use Illuminate\Console\Command;

class ImportPackage extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:import-pkg 
                            {path? : Relative path to the package file/folder/url}
                            {--password= : Password for encrypted package}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Import resources from a DreamFactory package (dfpkg) or zip file.';

    /**
     * Keeps track of errors when a file fails to import.
     *
     * @type array
     */
    protected $errors = [];

    /**
     * Keeps track of import logs of all files being imported.
     *
     * @type array
     */
    protected $importLog = [];

    /**
     * Create a new command instance.
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Runs the command.
     */
    public function handle()
    {
        $path = $this->getPath();

        if (is_file($path) || FileUtilities::url_exist($path)) {
            $this->importPackage($path);
            $this->printResult();
        } else if (is_dir($path)) {
            $files = static::getFilesFromPath($path);
            if (count($files) == 0) {
                $this->warn('No package to import from ' . $path);
            } else {
                foreach ($files as $file) {
                    try {
                        $this->importPackage($file);
                    } catch (\Exception $e) {
                        $this->errors[] = [
                            'file' => $file,
                            'msg'  => $e->getMessage()
                        ];
                    }
                }
                $this->printResult();
            }
        } else {
            $this->error('Invalid path ' . $path);
        }
    }

    /**
     * Prints result.
     */
    protected function printResult()
    {
        $errorCount = count($this->errors);
        if ($errorCount > 0) {
            $fileCount = count(static::getFilesFromPath($this->getPath()));
            if ($errorCount < $fileCount) {
                $this->warn('Not all files were imported successfully. See details below.');
            } else if ($errorCount == $fileCount) {
                $this->error('None of your files where imported successfully. See details below.');
            }
            $this->warn('---------------------------------------------------------------------------------------');
            foreach ($this->errors as $error) {
                $this->warn('Failed importing: ' . array_get($error, 'file'));
                $this->warn('Error: ' . array_get($error, 'msg'));
                $this->warn('---------------------------------------------------------------------------------------');
            }
        } else {
            $this->info('Successfully imported your file(s).');
        }
        $this->printImportLog();
    }

    /**
     * Imports package.
     *
     * @param $file
     *
     * @throws \Exception
     */
    protected function importPackage($file)
    {
        $extension = strtolower(pathinfo($file, PATHINFO_EXTENSION));

        if ($extension === Packager::FILE_EXTENSION) {
            $this->importOldPackage($file);
        } else {
            $package = new Package($file, false);
            $package->setPassword($this->option('password'));
            $importer = new Importer($package);
            $importer->import();
            $log = $importer->getLog();
            $this->importLog[] = [
                'file' => $file,
                'log'  => $log
            ];
        }
    }

    /**
     * Prints import log.
     */
    protected function printImportLog()
    {
        if (count($this->importLog) > 0) {
            $this->info('Import log');
            $this->info('---------------------------------------------------------------------------------------');
            foreach ($this->importLog as $il) {
                $this->info('Import File: ' . $il['file']);
                foreach ($il['log'] as $level => $logs) {
                    $this->info(strtoupper($level));
                    foreach ($logs as $log) {
                        $this->info('   -> ' . $log);
                    }
                }
                $this->info('---------------------------------------------------------------------------------------');
            }
        }
    }

    /**
     * Returns packaged file(s) from import path.
     *
     * @param $path
     *
     * @return array
     */
    protected static function getFilesFromPath($path)
    {
        $files = [];
        $path = rtrim($path, '/') . DIRECTORY_SEPARATOR;

        if (false !== $items = scandir($path)) {
            foreach ($items as $item) {
                $file = $path.$item;
                if (is_file($file)) {
                    $extension = strtolower(pathinfo($file, PATHINFO_EXTENSION));
                    if(in_array($extension, [Packager::FILE_EXTENSION, Package::FILE_EXTENSION])) {
                        $files[] = $file;
                    }
                }
            }
        }

        return $files;
    }

    /**
     * Imports old .dfpkg files.
     *
     * @param $file
     *
     * @throws \Exception
     */
    protected function importOldPackage($file)
    {
        $packager = new Packager($file);
        $packager->importAppFromPackage();
    }

    /**
     * Gets path to import package(s) from.
     *
     * @return array|string
     */
    protected function getPath()
    {
        $path = $this->argument('path');
        if (empty($path)) {
            $path = env('DF_PACKAGE_DIR');
        }

        return $path;
    }
}
