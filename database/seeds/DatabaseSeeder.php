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

        if ( class_exists( 'DreamFactory\\Rave\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\Rave\\SqlDb\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\SqlDb\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\Rave\\MongoDb\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\MongoDb\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\Rave\\CouchDb\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\CouchDb\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\Rave\\Rws\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\Rws\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\Rave\\Aws\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\Aws\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\Rave\\Azure\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\Azure\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\Rave\\Rackspace\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\Rackspace\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\Rave\\Salesforce\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\Rave\\Salesforce\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\DSP\\OAuth\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\DSP\\OAuth\\Database\\Seeds\\DatabaseSeeder' );
        }
        if ( class_exists( 'DreamFactory\\DSP\\ADLdap\\Database\\Seeds\\DatabaseSeeder' ) )
        {
            $this->call( 'DreamFactory\\DSP\\ADLdap\\Database\\Seeds\\DatabaseSeeder' );
        }
    }
}
