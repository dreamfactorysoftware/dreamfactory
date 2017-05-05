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

        $this->call(ServiceSeeder::class);
        $this->call(AppSeeder::class);
//        $this->call(EmailTemplateSeeder::class);
//        $this->call(UserServiceSeeder::class);
    }
}
