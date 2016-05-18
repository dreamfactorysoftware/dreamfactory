<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Core\Exceptions\RestException;
use DreamFactory\Library\Utility\Scalar;
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
    protected $description = 'Update pre-2.2 service types sql_db and script configuration to latest types.';

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
                    $configs = DB::table('sql_db_config')->whereIn('service_id', $ids)->get();
                    $this->info('|--------------------------------------------------------------------');
                    foreach ($configs as $entry) {
                        /** @type array $entry */
                        $entry = (array)$entry;
                        $dsn = array_get($entry, 'dsn');
                        $driver = array_get($entry, 'driver');
                        $newType = $driver;
                        $config = [];
                        switch ($driver) {
                            case 'ibm':
                                $newType = 'ibmdb2';
                                $config = static::adaptConfig($dsn);
                                break;
                            case 'oci':
                            case 'oracle':
                                $newType = 'oracle';
                                if (!empty($dsn)) {
                                    $dsn = str_replace(' ', '', $dsn);
                                    // traditional connection string uses (), reset find
                                    if (false !== ($pos = stripos($dsn, 'host='))) {
                                        $temp = substr($dsn, $pos + 5);
                                        $config['host'] =
                                            (false !== $pos = stripos($temp, ')')) ? substr($temp, 0, $pos) : $temp;
                                    }
                                    if (false !== ($pos = stripos($dsn, 'port='))) {
                                        $temp = substr($dsn, $pos + 5);
                                        $config['port'] =
                                            (false !== $pos = stripos($temp, ')')) ? substr($temp, 0, $pos) : $temp;
                                    }
                                    if (false !== ($pos = stripos($dsn, 'sid='))) {
                                        $temp = substr($dsn, $pos + 4);
                                        $config['database'] =
                                            (false !== $pos = stripos($temp, ')')) ? substr($temp, 0, $pos) : $temp;
                                    }
                                    if (false !== ($pos = stripos($dsn, 'service_name='))) {
                                        $temp = substr($dsn, $pos + 13);
                                        $config['service_name'] =
                                            (false !== $pos = stripos($temp, ')')) ? substr($temp, 0, $pos) : $temp;
                                    }
                                }
                                break;
                            case 'sqlite':
                                if (!empty($dsn)) {
                                    // default PDO DSN pieces
                                    $dsn = str_replace(' ', '', $dsn);
                                    $file = substr($dsn, 7);
                                    $config['database'] = $file;
                                }
                                break;
                            case 'dblib':
                            case 'sqlsrv':
                                $newType = 'sqlsrv';
                                if (!empty($dsn)) {
                                    // default PDO DSN pieces
                                    $config = static::adaptConfig($dsn);
                                    // SQL Server native driver specifics
                                    if (!isset($config['host']) && (false !== ($pos = stripos($dsn, 'Server=')))) {
                                        $temp = substr($dsn, $pos + 7);
                                        $host = (false !== $pos = stripos($temp, ';')) ? substr($temp, 0, $pos) : $temp;
                                        if (!isset($config['port']) && (false !== ($pos = stripos($host, ',')))) {
                                            $temp = substr($host, $pos + 1);
                                            $host = substr($host, 0, $pos);
                                            $config['port'] =
                                                (false !== $pos = stripos($temp, ';')) ? substr($temp, 0, $pos) : $temp;
                                        }
                                        $config['host'] = $host;
                                    }
                                    if (!isset($config['database']) &&
                                        (false !== ($pos = stripos($dsn, 'Database=')))
                                    ) {
                                        $temp = substr($dsn, $pos + 9);
                                        $config['database'] =
                                            (false !== $pos = stripos($temp, ';')) ? substr($temp, 0, $pos) : $temp;
                                    }
                                }
                                break;
                            case 'sqlanywhere':
                            case 'pgsql':
                            case 'mysql':
                                $config = static::adaptConfig($dsn);
                                break;
                            default:
                                continue 2;
                        }
                        $id = array_get($entry, 'service_id');
                        $this->info('| ID: ' . $id . ' New Type: ' . $newType);
                        $config['username'] = array_get($entry, 'username');
                        $config['password'] = array_get($entry, 'password');
                        if (Scalar::boolval(array_get($entry, 'default_schema_only', false))) {
                            $config['default_schema_only'] = true;
                        }
                        $config = json_encode($config);
                        $this->info('| Service ID: ' . $id . ' New Config: ' . $config);
                        if (!$pretend) {
                            DB::table('service')->where('id', $id)->update(['type' => $newType]);
                            DB::table('sql_db_config')->where('service_id', $id)->update(['connection' => $config]);
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

    public static function adaptConfig($dsn = '')
    {
        if (empty($dsn)) {
            return [];
        }

        $config = [];
        // default PDO DSN pieces
        $dsn = str_replace(' ', '', $dsn);
        if (false !== ($pos = strpos($dsn, 'port='))) {
            $temp = substr($dsn, $pos + 5);
            $config['port'] = (false !== $pos = strpos($temp, ';')) ? substr($temp, 0, $pos) : $temp;
        }
        if (false !== ($pos = strpos($dsn, 'host='))) {
            $temp = substr($dsn, $pos + 5);
            $host = (false !== $pos = stripos($temp, ';')) ? substr($temp, 0, $pos) : $temp;
            if (!isset($config['port']) && (false !== ($pos = stripos($host, ':')))) {
                $temp = substr($host, $pos + 1);
                $host = substr($host, 0, $pos);
                $config['port'] = (false !== $pos = stripos($temp, ';')) ? substr($temp, 0, $pos) : $temp;
            }
            $config['host'] = $host;
        }
        if (false !== ($pos = strpos($dsn, 'dbname='))) {
            $temp = substr($dsn, $pos + 7);
            $config['database'] = (false !== $pos = strpos($temp, ';')) ? substr($temp, 0, $pos) : $temp;
        }
        if (false !== ($pos = strpos($dsn, 'charset='))) {
            $temp = substr($dsn, $pos + 8);
            $config['charset'] = (false !== $pos = strpos($temp, ';')) ? substr($temp, 0, $pos) : $temp;
        } else {
            $config['charset'] = 'utf8';
        }

        return $config;
    }
}
