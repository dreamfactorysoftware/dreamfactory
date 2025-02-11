<?php

use DreamFactory\Core\Models\Service;
use Illuminate\Database\Seeder;

class SystemServiceSeeder extends Seeder
{
    public function run()
    {
        $system = [
            'name'        => 'system',
            'label'       => 'System Management',
            'description' => 'Service for managing system resources.',
            'is_active'   => true,
            'type'        => 'system',
            'config'      => [],
        ];

        if (!Service::whereName('system')->exists()) {
            Service::create($system);
        }
    }
} 