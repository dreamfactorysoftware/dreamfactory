<?php

namespace DreamFactory\Console\Commands;

use DreamFactory\Core\ADLdap\Models\RoleADLdap;
use DreamFactory\Core\Enums\ServiceTypeGroups;
use DreamFactory\Core\Exceptions\BadRequestException;
use DreamFactory\Core\Exceptions\RestException;
use DreamFactory\Core\Models\Service;
use DreamFactory\Core\Utility\ResourcesWrapper;
use DreamFactory\Core\Utility\ServiceHandler;
use DreamFactory\Core\ADLdap\Services\ADLdap;
use DreamFactory\Library\Utility\Enums\Verbs;
use Illuminate\Console\Command;

class ADGroupImport extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dreamfactory:ad-group-import {service} {--username=} {--password=}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Imports Active Directory groups as roles.';

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
        if(!class_exists('DreamFactory\\Core\\ADLdap\\Services\\ADLdap')){
            $this->error('Command unavailable. Please install \'dreamfactory/df-adldap\' package to use this command.');
            return;
        }

        try {
            $serviceName = $this->argument('service');
            $username = $this->option('username');
            $password = $this->option('password');

            /** @type ADLdap $service */
            $service = ServiceHandler::getService($serviceName);
            $serviceModel = Service::find($service->getServiceId());
            $serviceType = $serviceModel->serviceType()->first();
            $serviceGroup = $serviceType->group;

            if ($serviceGroup !== ServiceTypeGroups::LDAP) {
                throw new BadRequestException('Invalid service name [' .
                    $serviceName .
                    ']. Please use a valid Active Directory service');
            }

            $this->line('Contacting your Active Directory server...');
            $service->authenticateAdminUser($username, $password);

            $this->line('Fetching Active Directory groups...');
            $groups = $service->getDriver()->listGroup(['dn', 'description']);
            $roles = [];

            foreach ($groups as $group) {
                $dfRole = RoleADLdap::whereDn($group['dn'])->first();
                if (empty($dfRole)) {
                    $role = [
                        'name'                   => static::dnToRoleName($group['dn']),
                        'description'            => $group['description'],
                        'is_active'              => true,
                        'role_adldap_by_role_id' => [
                            [
                                'dn' => $group['dn']
                            ]
                        ]
                    ];

                    $this->info('|--------------------------------------------------------------------');
                    $this->info('| DN: ' . $group['dn']);
                    $this->info('| Role Name: ' . $role['name']);
                    $this->info('| Description: ' . $role['description']);
                    $this->info('|--------------------------------------------------------------------');

                    $roles[] = $role;
                }
            }

            $roleCount = count($roles);
            if ($roleCount > 0) {
                $this->warn('Total Roles to import: [' . $roleCount . ']');
                if ($this->confirm('The above roles will be imported into your DreamFactroy instance based on your Active Directory groups. Do you wish to continue?')) {
                    $this->line('Importing Roles...');
                    $payload = ResourcesWrapper::wrapResources($roles);
                    ServiceHandler::handleRequest(Verbs::POST, 'system', 'role', ['continue' => true], $payload);
                    $this->info('Successfully imported all Active Directory groups as Roles.');
                } else {
                    $this->info('Aborted import process. No Roles were imported');
                }
            } else if (count($groups) > 0 && $roleCount === 0) {
                $this->info('All groups found on the Active Directory server are already imported.');
            } else {
                $this->warn('No group was found on Active Directory server.');
            }
        } catch (RestException $e) {
            $this->error($e->getMessage());
            if ($this->option('verbose')) {
                $this->error(print_r($e->getContext(), true));
            }
        } catch (\Exception $e) {
            $this->error($e->getMessage());
        }
    }

    public static function dnToRoleName($dn)
    {
        $attributes = explode(',', $dn);
        $attValues = [];

        foreach ($attributes as $attribute) {
            $value = substr($attribute, 3);
            $attValues[] = str_replace(' ', '', $value);
        }

        $roleName = implode('+', $attValues);

        if (strlen($roleName) > 64) {
            $roleName = substr($roleName, 0, 59) . '_' . sprintf("%04d", mt_rand(1, 9999));
        }

        return $roleName;
    }
}
