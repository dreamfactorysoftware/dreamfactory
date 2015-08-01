<?php namespace Dreamfactory;

class Application extends \Illuminate\Foundation\Application
{
    /**
     * Get the path to the storage directory.
     *
     * @return string
     */
    public function storagePath()
    {
        return config('df.storage_path');
    }
}
