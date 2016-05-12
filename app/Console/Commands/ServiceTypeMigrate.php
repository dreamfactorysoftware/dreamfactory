<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Core\Exceptions\RestException;
use Illuminate\Console\Command;
use DB;
use Schema;

class ServiceTypeMigrate extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:service-type-migrate
                            {--pretend : Dump the SQL updates that would be run.}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update pre-2.2 service types sql_db and script to more specific types.';

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
        try {
            $pretend = $this->option('pretend');
            if ($pretend) {
                $this->info('Pretending...');
            }

            if (Schema::hasTable('service_type')) {
                $this->info('Scanning database for old sql_db service type...');
                $ids = DB::table('service')->where('type', 'sql_db')->pluck('id');
                if (!empty($ids)) {
                    $configs = DB::table('sql_db_config')->whereIn('service_id', $ids)->pluck('driver', 'service_id');
                    $this->info('|--------------------------------------------------------------------');
                    foreach ($configs as $id => $driver) {
                        $newType = $driver;
                        switch ($driver) {
                            case 'ibm':
                                $newType = 'ibmdb2';
                                break;
                            case 'oci':
                                $newType = 'oracle';
                                break;
                            case 'dblib':
                                $newType = 'sqlsrv';
                                break;
                            case 'oracle':
                            case 'pgsql':
                            case 'sqlite':
                            case 'mysql':
                            case 'sqlsrv':
                            case 'sqlanywhere':
                                // same
                                break;
                            default:
                                continue 2;
                        }
                        $this->info('| ID: ' . $id . ' New Type: ' . $newType);
                        if (!$pretend) {
                            DB::table('service')->where('id', $id)->update(['type' => $newType]);
                        }
                    }
                    $this->info('|--------------------------------------------------------------------');
                }
            }

            if (Schema::hasTable('service_type')) {
                $this->info('Scanning database for old script service type...');
                $ids = DB::table('service')->where('type', 'script')->pluck('id');
                if (!empty($ids)) {
                    $configs = DB::table('script_config')->whereIn('service_id', $ids)->pluck('type', 'service_id');
                    $this->info('|--------------------------------------------------------------------');
                    foreach ($configs as $id => $driver) {
                        $newType = $driver;
                        $this->info('| ID: ' . $id . ' New Type: ' . $newType);
                        if (!$pretend) {
                            DB::table('service')->where('id', $id)->update(['type' => $newType]);
                        }
                    }
                    $this->info('|--------------------------------------------------------------------');
                }
            }
        } catch (RestException $e) {
            $this->error($e->getMessage());
            if ($this->option('verbose')) {
                $this->error(print_r($e->getContext(), true));
            }
        } catch (\Exception $e) {
            $msg = $e->getMessage();
            $this->error($msg);
            if (strpos($msg, 'Sizelimit exceeded') !== false) {
                $this->error('Please use "--filter=" option to avoid exceeding Sizelimit');
            }
        }
    }
}
