<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Core\Models\User;
use DreamFactory\Core\Utility\FileUtilities;
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
    protected $description = 'Setup DreamFactory 2.0 instance.';

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

        if ($this->isConfigRequired()) {
            $this->runConfig();

            return;
        }

        $this->info('**********************************************************************************************************************');
        $this->info('* Welcome to DreamFactory setup wizard.');
        $this->info('**********************************************************************************************************************');

        $this->info('Running Migrations...');
        $this->call('migrate', ['--force' => $force]);
        $this->info('Migration completed successfully.');
        $this->info('**********************************************************************************************************************');

        $this->info('**********************************************************************************************************************');
        $this->info('Running Seeder...');
        $this->call('db:seed', ['--force' => $force]);
        $this->info('All tables were seeded successfully.');
        $this->info('**********************************************************************************************************************');

        $this->info('**********************************************************************************************************************');
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
                $this->info('Please try again...');
            }
        }
        $this->info('Successfully created first admin user.');
        $this->info('**********************************************************************************************************************');

        $this->dirWarn();
        $this->info('*********************************************** Setup Successful! ****************************************************');
        $this->info('* Setup is complete! Your instance is ready. Please launch your instance using a browser.');
        $this->info('* You can run "php artisan serve" to try out your instance without setting up a web server.');
        $this->info('**********************************************************************************************************************');
    }

    /**
     * Directory permission warning.
     */
    protected function dirWarn()
    {
        $this->warn('*************************************************** WARNING! *********************************************************');
        $this->warn('* Please make sure following directories and all directories under them are readable and writable by your web server ');
        $this->warn('*   -> storage/');
        $this->warn('*   -> bootstrap/cache/');
        $this->warn('* Example:');
        $this->warn('*      > sudo chown -R {www user}:{your user group} storage/ bootstrap/cache/ ');
        $this->warn('*      > sudo chmod -R 2775 storage/ bootstrap/cache/ ');
        $this->warn('**********************************************************************************************************************');
    }

    /**
     * Configures the .env file with app key and database configuration.
     */
    protected function runConfig()
    {
        $this->info('**********************************************************************************************************************');
        $this->info('* Configuring DreamFactory... ');
        $this->info('**********************************************************************************************************************');

        if (!file_exists('.env')) {
            copy('.env-dist', '.env');
            $this->info('Created .env file with default configuration.');
            $this->call('key:generate');
        }

        if (!file_exists('phpunit.xml')) {
            copy('phpunit.xml-dist', 'phpunit.xml');
            $this->info('Created phpunit.xml with default configuration.');
        }

        $db = $this->choice('Which database would you like to use for system tables?',
            ['sqlite', 'mysql', 'pgsql'], 0);

        if ('sqlite' === $db) {
            $this->createSqliteDbFile();
        } else {
            $driver = $db;
            $host = $this->ask('Enter your ' . $db . ' Host');
            $database = $this->ask('Enter your database name');
            $username = $this->ask('Enter your database username');

            $password = '';
            $passwordMatch = false;
            while (!$passwordMatch) {
                $password = $this->secret('Enter your database password');
                $password2 = $this->secret('Re-enter your database password');

                if ($password === $password2) {
                    $passwordMatch = true;
                } else {
                    $this->error('Passwords did not match. Please try again.');
                }
            }

            $port = $this->ask('Enter your Database Port', config('database.connections.'.$db.'.port'));

            $config = [
                'DB_DRIVER'   => $driver,
                'DB_HOST'     => $host,
                'DB_DATABASE' => $database,
                'DB_USERNAME' => $username,
                'DB_PASSWORD' => $password,
                'DB_PORT'     => $port
            ];

            FileUtilities::updateEnvSetting($config);
            $this->info('Configured ' . $db . ' Database');
        }

        $this->info('Configuration complete!');
        $this->configComplete();
    }

    /**
     * Shows config completion warning.
     */
    protected function configComplete()
    {
        $this->warn('*************************************************** WARNING! *********************************************************');
        $this->warn('*');
        $this->warn('* Please take a moment to review the .env file. You can make any changes as necessary there. ');
        $this->warn('*');
        $this->warn('* Please run "php artisan dreamfactory:setup" again to complete the setup process.');
        $this->warn('*');
        $this->warn('**********************************************************************************************************************');
    }

    /**
     * Creates SQLite database file.
     */
    protected function createSqliteDbFile()
    {
        if (!file_exists('storage/databases/database.sqlite')) {
            touch('storage/databases/database.sqlite');
            $this->info('Created SQLite database file at storage/databases/database.sqlite');
        }
    }

    /**
     * Checks to see if .env file is configured or not.
     *
     * @return bool
     */
    protected function isConfigRequired()
    {
        if (!file_exists('.env')) {
            return true;
        }

        return false;
    }
}
