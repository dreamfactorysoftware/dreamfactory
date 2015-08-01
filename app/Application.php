<?php namespace Dreamfactory;

class Application extends \Illuminate\Foundation\Application
{

    public static $storage_path;

    public function __construct($basePath = null)
    {
        parent::__construct($basePath);

//        static::$storage_path = $this->basePath . DIRECTORY_SEPARATOR . 'storage';
    }
    /**
     * Get the path to the storage directory.
     *
     * @return string
     */
    public function storagePath()
    {
        return $this->basePath . DIRECTORY_SEPARATOR . 'storage';
    }
}
