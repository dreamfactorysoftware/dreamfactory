<?php

use DreamFactory\Core\Models\Seeds\AppSeeder;
use DreamFactory\Core\Models\Seeds\ServiceSeeder;
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

        $this->call(ServiceSeeder::class);
        $this->call(AppSeeder::class);

        if (class_exists('DreamFactory\\Core\\User\\Models\\Seeds\\DatabaseSeeder')) {
            $this->call('DreamFactory\\Core\\User\\Models\\Seeds\\DatabaseSeeder');
        }
    }
}
