<?php

use DreamFactory\Core\Models\App;

class AppSeeder extends BaseModelSeeder
{
    protected $modelClass = App::class;

    protected $allowUpdate = true;

    protected function getRecords()
    {
        return [
            [
                'name' => 'admin',
                'api_key' => '6498a8ad1beb9d84d63035c5d1120c007fad6de706734db9689f8996707e0f7d',
                'description' => 'An application for administering this instance.',
                'is_active' => true,
                'type' => 3,
                'path' => 'dreamfactory/dist/index.html',
            ],
            [
                'name' => 'api_docs',
                'api_key' => '36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88',
                'description' => 'An OpenAPI-based application allowing documentation viewing and testing of the API.',
                'is_active' => true,
                'type' => 3,
                'path' => 'df-api-docs-ui/dist/index.html',
            ],
            [
                'name' => 'file_manager',
                'api_key' => 'b5cb82af7b5d4130f36149f90aa2746782e59a872ac70454ac188743cb55b0ba',
                'description' => 'An application for managing file services.',
                'is_active' => true,
                'type' => 3,
                'path' => 'filemanager/index.html',
            ],
        ];
    }
}
