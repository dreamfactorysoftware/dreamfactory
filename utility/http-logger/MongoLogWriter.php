<?php

namespace Utility\HttpLogger;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\File\UploadedFile;

class MongoLogWriter implements \Spatie\HttpLogger\LogWriter
{
    public function logRequest(Request $request)
    {
        $method = strtoupper($request->getMethod());

        $uri = $request->getPathInfo();

        $bodyAsJson = json_encode($request->except(config('http-logger.except')));

        $files = array_map(function (UploadedFile $file) {
            return $file->path();
        }, iterator_to_array($request->files));

        $timestamp = \Carbon\Carbon::now();

        $message = "{$method} {$uri} - Body: {$bodyAsJson} - Files: ".implode(', ', $files);

        \DB::connection('logsdb')->collection('access')->insert(
            [
                'timestamp' => $timestamp->toDateTimeString(),
                'method' => $method,
                'uri' => $uri,
                'body' => $bodyAsJson,
                'expireAt' => new \MongoDB\BSON\UTCDateTime(\Carbon\Carbon::now()->addDays(45)->getTimestamp()*1000)
            ]
        );

        Log::info($message);
    }
}
