<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Core\Enums\DataFormats;
use DreamFactory\Core\Models\User;
use DreamFactory\Core\Utility\ServiceHandler;
use DreamFactory\Library\Utility\Enums\Verbs;
use Illuminate\Console\Command;

class Setup extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:setup {--force}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description.';

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
            try {
                if (!User::adminExists()) {
                    $this->runSetup();
                } else {
                    $this->error('Your instance is already setup.');
                }
            } catch (\Exception $e) {
                $this->runSetup();
            }
        } catch (\Exception $e) {
            $this->error($e->getMessage());
        }
    }

    /**
     * Run the setup process.
     *
     * @throws \DreamFactory\Core\Exceptions\BadRequestException
     */
    protected function runSetup()
    {
        $force = $this->option('force');

        $this->info('Welcome to DreamFactory 2.0 setup wizard.');
        $this->info('Running Migrations...');
        $this->call('migrate', ['--force' => $force]);

        $this->info('Running Seeder...');
        $this->call('db:seed', ['--force' => $force]);

        $this->info('Creating the first admin user...');
        $user = false;
        while (!$user) {
            $firstName = $this->ask('Enter your first name');
            $lastName = $this->ask('Enter your last name');
            $displayName = $this->ask('Enter display name');
            $displayName = empty($displayName) ? $firstName . ' ' . $lastName : $displayName;
            $email = $this->ask('Enter your email address?');
            $password = $this->secret('Choose a password');
            $passwordConfirm = $this->secret('Re-enter password');

            $data = [
                'first_name'            => $firstName,
                'last_name'             => $lastName,
                'email'                 => $email,
                'password'              => $password,
                'password_confirmation' => $passwordConfirm,
                'name'                  => $displayName
            ];

            $user = User::createFirstAdmin($data);

            if (!$user) {
                $this->error('Failed to create user.' . print_r($data['errors'], true));
                $this->dirWarn();
                $this->info('Please try again...');
            }
        }

        $this->dirWarn();
        $this->info('Setup complete! Please launch your instance using a browser.');
    }

    /**
     * Directory permission warning.
     */
    protected function dirWarn()
    {
        $this->warn('************************************************* WARNING! ***********************************************************');
        $this->warn('* Please make sure following directories and all directories under them are readable and writable by your web server ');
        $this->warn('*   -> storage/');
        $this->warn('*   -> bootstrap/cache/');
        $this->warn('**********************************************************************************************************************');
    }
}
