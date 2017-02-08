<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Filesystem Disk
    |--------------------------------------------------------------------------
    |
    | Here you may specify the default filesystem disk that should be used
    | by the framework. The "local" disk, as well as a variety of cloud
    | based disks are available to your application. Just store away!
    |
    */

    'default' => 'local',

    /*
    |--------------------------------------------------------------------------
    | Default Cloud Filesystem Disk
    |--------------------------------------------------------------------------
    |
    | Many applications store files both locally and in the cloud. For this
    | reason, you may specify a default "cloud" driver here. This driver
    | will be bound as the Cloud disk implementation in the container.
    |
    */

    'cloud' => 's3',

    /*
    |--------------------------------------------------------------------------
    | Filesystem Disks
    |--------------------------------------------------------------------------
    |
    | Here you may configure as many filesystem "disks" as you wish, and you
    | may even configure multiple disks of the same driver. Defaults have
    | been setup for each driver as an example of the required options.
    |
    | Supported Drivers: "local", "ftp", "s3", "rackspace"
    |
    */

    'disks' => [

        'local' => [
            'driver' => 'local',
            'root' => env('DF_MANAGED_STORAGE_PATH', storage_path()) . DIRECTORY_SEPARATOR . ltrim(env('DF_LOCAL_FILE_ROOT', 'app'), '/'),
        ],

        'public' => [
            'driver' => 'local',
            'root' => storage_path('app/public'),
            'url' => env('APP_URL').'/storage',
            'visibility' => 'public',
        ],

        'logs' => [
            'driver' => 'local',
            'root' => env('DF_MANAGED_LOG_PATH', storage_path('logs')),
        ],

//        's3'        => [
//            'driver' => 's3',
//            'key'    => env('AWS_KEY'),
//            'secret' => env('AWS_SECRET'),
//            'region' => env('AWS_REGION'),
//            'bucket' => env('AWS_CONTAINER'),
//        ],
//        'rackspace' => [
//            'driver'       => 'rackspace',
//            'username'     => env('ROS_USERNAME'),
//            'password'     => env('ROS_PASSWORD'),
//            'tenant_name'  => env('ROS_TENANT_NAME'),
//            'container'    => env('ROS_CONTAINER'),
//            'url'          => env('ROS_URL'),
//            'region'       => env('ROS_REGION'),
//            'storage_type' => env('ROS_STORAGE_TYPE'),
//        ],
//        'azure'     => [
//            'driver'       => 'azure',
//            'account_name' => env('AZURE_ACCOUNT_NAME'),
//            'account_key'  => env('AZURE_ACCOUNT_KEY'),
//            'protocol'     => 'https',
//            'container'    => env('AZURE_BLOB_CONTAINER'),
//        ],
    ],

];
