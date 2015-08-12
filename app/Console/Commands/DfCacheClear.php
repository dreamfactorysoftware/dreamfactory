<?php namespace DreamFactory\Console\Commands;

use Illuminate\Console\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;

class DfCacheClear extends Command {

	/**
	 * The console command name.
	 *
	 * @var string
	 */
	protected $name = 'dfcache:clear';

	/**
	 * The console command description.
	 *
	 * @var string
	 */
	protected $description = 'Command to clear DreamFactory cache.';

	protected $cacheRoot = '';

	/**
	 * Create a new command instance.
	 */
	public function __construct()
	{
		parent::__construct();
		$this->cacheRoot = storage_path().'/framework/cache/';
	}

	/**
	 * Execute the console command.
	 *
	 * @return mixed
	 */
	public function fire()
	{
		$this->removeDirectory($this->cacheRoot);
		$this->info('Cleared DreamFactory cache ');
	}

	/**
	 * Get the console command arguments.
	 *
	 * @return array
	 */
	protected function getArguments()
	{
		return [
			['example', InputArgument::OPTIONAL, 'An example argument.'],
		];
	}

	/**
	 * Get the console command options.
	 *
	 * @return array
	 */
	protected function getOptions()
	{
		return [
			['example', null, InputOption::VALUE_OPTIONAL, 'An example option.', null],
		];
	}

	/**
	 * Removes directories recursively.
	 *
	 * @param $path
	 */
	protected function removeDirectory($path) {
		$files = glob($path . '/*');
		foreach ($files as $file) {
			if(is_dir($file)){
				static::removeDirectory($file);
			} else if(basename($file)!=='.gitignore'){
				unlink($file);
			}
		}
		if($path !== $this->cacheRoot) {
			rmdir($path);
		}
		return;
	}
}
