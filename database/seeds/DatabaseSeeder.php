<?php

use Illuminate\Database\Seeder;
use Illuminate\Database\Eloquent\Model;

class DatabaseSeeder extends Seeder
{

    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        Model::unguard();

        if (class_exists('DreamFactory\\Core\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\SqlDb\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\SqlDb\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\MongoDb\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\MongoDb\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\CouchDb\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\CouchDb\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\Rws\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\Rws\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\Aws\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\Aws\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\Azure\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\Azure\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\Rackspace\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\Rackspace\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\Salesforce\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\Salesforce\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\User\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\User\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\OAuth\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\OAuth\\Database\\Seeds\\DatabaseSeeder');
        }
        if (class_exists('DreamFactory\\Core\\ADLdap\\Database\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\ADLdap\\Database\\Seeds\\DatabaseSeeder');
        }
    }
}
