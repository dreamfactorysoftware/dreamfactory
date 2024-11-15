<?php

use DreamFactory\Core\Models\EmailTemplate;
use DreamFactory\Core\Models\Service;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Seeder;
use Illuminate\Support\Arr;

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

        // First, ensure all migrations are run
        try {
            \Artisan::call('migrate', ['--force' => true]);
        } catch (\Exception $e) {
            \Log::error('Migration failed: ' . $e->getMessage());
            throw $e;
        }

        // Run this first to ensure system service exists
        $systemService = [
            'name'        => 'system',
            'label'       => 'System Management',
            'description' => 'Service for managing system resources.',
            'is_active'   => true,
            'type'        => 'system',
            'mutable'     => false,
            'deletable'   => false,
            'config'      => []
        ];

        $this->seedModel('DreamFactory\Core\Models\Service', [$systemService]);

        // Then run the rest of the seeders
        $this->call(AppSeeder::class);
        $this->call(EmailTemplateSeeder::class);
        
        // Ensure File ServiceProvider is registered and booted
        if (!app()->bound('df.file')) {
            app()->register(\DreamFactory\Core\File\ServiceProvider::class);
        }
        
        // Now create services
        $class = 'DreamFactory\Core\Models\Service';
        $records = [
            [
                'name' => 'system',
                'label' => 'System Management',
                'description' => 'Service for managing system resources.',
                'is_active' => true,
                'type' => 'system',
                'mutable' => false,
                'deletable' => false,
            ],
        ];

        if (class_exists('DreamFactory\Core\ApiDoc\ServiceProvider')) {
            $records[] = [
                'name' => 'api_docs',
                'label' => 'Live API Docs',
                'description' => 'API documenting and testing service.',
                'is_active' => true,
                'type' => 'swagger',
                'mutable' => false,
                'deletable' => false,
            ];
        }
        if (class_exists('DreamFactory\Core\File\ServiceProvider')) {
            $records[] = [
                'name' => 'files',
                'label' => 'Local File Storage',
                'description' => 'Service for accessing local file storage.',
                'is_active' => true,
                'type' => 'local_file',
                'mutable' => true,
                'deletable' => true,
                'config' => ['container' => 'app'],
            ];
            $records[] = [
                'name' => 'logs',
                'label' => 'Local Log Storage',
                'description' => 'Service for accessing local log storage.',
                'is_active' => true,
                'type' => 'local_file',
                'mutable' => true,
                'deletable' => true,
                'config' => ['container' => 'logs'],
            ];
        }
        if (class_exists('DreamFactory\Core\SqlDb\ServiceProvider')) {
            $records[] = [
                'name' => 'db',
                'label' => 'Local SQL Database',
                'description' => 'Service for accessing local SQLite database.',
                'is_active' => true,
                'type' => 'sqlite',
                'mutable' => true,
                'deletable' => true,
                'config' => ['database' => 'db.sqlite'],
            ];
        }
        if (class_exists('DreamFactory\Core\Email\ServiceProvider')) {
            $records[] = [
                'name' => 'email',
                'label' => 'Local Email Service',
                'description' => 'Email service used for sending user invites and/or password reset confirmation.',
                'is_active' => true,
                'type' => 'local_email',
                'mutable' => true,
                'deletable' => true,
            ];
        }
        $this->seedModel($class, $records);

        $emailService = Service::whereName('email')->first();
        $emailServiceId = (! empty($emailService)) ? $emailService->id : null;
        $emailTemplateInvite = EmailTemplate::whereName('User Invite Default')->first();
        $emailTemplateInviteId = (! empty($emailTemplateInvite)) ? $emailTemplateInvite->id : null;
        $emailTemplatePassword = EmailTemplate::whereName('Password Reset Default')->first();
        $emailTemplatePasswordId = (! empty($emailTemplatePassword)) ? $emailTemplatePassword->id : null;
        $emailTemplateOpenReg = EmailTemplate::whereName('User Registration Default')->first();
        $emailTemplateOpenRegId = (! empty($emailTemplateOpenReg)) ? $emailTemplateOpenReg->id : null;
        if ($system = Service::whereName('system')->first()) {
            if (Arr::get($system->config, 'invite_email_service_id') == null) {
                $record = [
                    'config' => [
                        'invite_email_service_id' => $emailServiceId,
                        'invite_email_template_id' => $emailTemplateInviteId,
                        'password_email_service_id' => $emailServiceId,
                        'password_email_template_id' => $emailTemplatePasswordId,
                    ],
                ];
                $system->update($record);
                $this->command->info('System service updated.');
            }
        }
        if (class_exists('DreamFactory\Core\User\ServiceProvider')) {
            $records = [
                [
                    'name' => 'user',
                    'label' => 'User Management',
                    'description' => 'Service for managing system users.',
                    'is_active' => true,
                    'type' => 'user',
                    'mutable' => true,
                    'deletable' => false,
                    'config' => [
                        'allow_open_registration' => false,
                        'open_reg_email_service_id' => $emailServiceId,
                        'open_reg_email_template_id' => $emailTemplateOpenRegId,
                        'invite_email_service_id' => $emailServiceId,
                        'invite_email_template_id' => $emailTemplateInviteId,
                        'password_email_service_id' => $emailServiceId,
                        'password_email_template_id' => $emailTemplatePasswordId,
                    ],
                ],
            ];
            $this->seedModel($class, $records);
        }
    }

    /**
     * Run the database seeds.
     *
     * @param  string  $class_name
     * @param  string  $identifier
     * @param  bool  $allow_update
     *
     * @throws Exception
     */
    public function seedModel($class_name, array $records, $identifier = 'name', $allow_update = false)
    {
        if (empty($class_name)) {
            throw new \Exception('Invalid seeder model.');
        } elseif (! class_exists($class_name)) {
            return;
        }

        $created = [];
        $updated = [];
        foreach ($records as $record) {
            /** @type \Illuminate\Database\Eloquent\Builder $builder */
            $builder = null;
            $name = '';
            if (! is_array($identifier)) {
                $name = Arr::get($record, $identifier);
                if (empty($name)) {
                    throw new \Exception("Invalid seeder record. No value for $identifier.");
                }
                $builder = $class_name::where($identifier, $name);
            } else {
                foreach ($identifier as $each) {
                    $id = Arr::get($record, $each);
                    if (empty($id)) {
                        throw new \Exception("Invalid seeder record. No value for $each.");
                    }
                    $builder =
                        (! $builder) ? $class_name::where($each, $id) : $builder->where($each, $id);
                    $name .= (empty($name)) ? $id : ':'.$id;
                }
            }
            if (! $builder->exists()) {
                // seed the record
                $class_name::create($record);
                $created[] = $name;
            } elseif ($allow_update) {
                // update an existing record
                $builder->first()->update($record);
                $updated[] = $name;
            }
        }

        $msg = static::separateWords(static::getModelBaseName($class_name)).' resources';

        if (! empty($created)) {
            $this->command->info($msg.' created: '.implode(', ', $created));
        }
        if (! empty($updated)) {
            $this->command->info($msg.' updated: '.implode(', ', $updated));
        }
    }

    public static function getModelBaseName($fqcn)
    {
        if (preg_match('@\\\\([\w]+)$@', $fqcn, $matches)) {
            $fqcn = $matches[1];
        }

        return $fqcn;
    }

    public static function separateWords($string)
    {
        return preg_replace('/([a-z])([A-Z])/', '\\1 \\2', $string);
    }

    protected $seeders = [
        // ... other seeders ...
        SystemServiceSeeder::class,
    ];
}
