<?php

use DreamFactory\Core\Models\EmailTemplate;
use DreamFactory\Core\Models\Service;

class UserServiceSeeder extends BaseModelSeeder
{
    protected $modelClass = Service::class;

    protected $records = [
        [
            'name'        => 'user',
            'label'       => 'User Management',
            'description' => 'Service for managing system users.',
            'is_active'   => true,
            'type'        => 'user',
            'mutable'     => true,
            'deletable'   => false,
        ]
    ];

    protected function getRecordExtras()
    {
        $emailService = Service::whereName('email')->first();
        $emailTemplateInvite = EmailTemplate::whereName('User Invite Default')->first();
        $emailTemplatePassword = EmailTemplate::whereName('Password Reset Default')->first();
        $emailTemplateOpenReg = EmailTemplate::whereName('User Registration Default')->first();

        return [
            'config' => [
                'allow_open_registration'    => false,
                'open_reg_email_service_id'  => (!empty($emailService)) ? $emailService->id : null,
                'open_reg_email_template_id' => (!empty($emailTemplateOpenReg)) ? $emailTemplateOpenReg->id : null,
                'invite_email_service_id'    => (!empty($emailService)) ? $emailService->id : null,
                'invite_email_template_id'   => (!empty($emailTemplateInvite)) ? $emailTemplateInvite->id : null,
                'password_email_service_id'  => (!empty($emailService)) ? $emailService->id : null,
                'password_email_template_id' => (!empty($emailTemplatePassword)) ? $emailTemplatePassword->id : null,
            ]
        ];
    }
}