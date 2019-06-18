<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateAccess extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {

        //Schema::connection('logsdb')->create('access')->ensureIndex('expireAt', ['expireAfterSeconds' => 20]);

        Schema::connection('logsdb')->create('access', function ($collection) {
            $collection->expire('expireAt', 1);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::connection('logsdb')->drop(['access']);
    }
}
