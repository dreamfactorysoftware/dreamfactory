<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Core\Enums\DataFormats;
use DreamFactory\Core\Utility\FileUtilities;
use DreamFactory\Core\Utility\ServiceHandler;
use DreamFactory\Library\Utility\Enums\Verbs;
use Illuminate\Console\Command;

class Request extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:request {data?} {--verb=get} {--service=system} {--resource=} {--format=json}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Perform a request on a service.';

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
        try {
            $data = $this->argument('data');
            if (filter_var($data, FILTER_VALIDATE_URL)) {
                // need to download file
                $data = FileUtilities::importUrlFileToTemp($data);
            }

            if (is_file($data)) {
                $data = file_get_contents($data);
            }

            $format = $this->option('format');
            $format = DataFormats::toNumeric($format);

            $verb = strtoupper($this->option('verb'));
            $service = $this->option('service');
            $resource = $this->option('resource');
            $result = ServiceHandler::handleRequest($verb, $service, $resource, [], $data, $format);
            $this->info(print_r($result, true));

            $this->info('Request complete!');
        } catch (\Exception $e) {
            $this->error($e->getMessage());
        }
    }
}
