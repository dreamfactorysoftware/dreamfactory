<?php

namespace Utility\HttpLogger;

use Illuminate\Http\Request;

class AllMethodsLogger implements \Spatie\HttpLogger\LogProfile
{
    public function shouldLogRequest(Request $request): bool
    {
        return in_array(strtolower($request->method()), ['get', 'post', 'put', 'patch', 'delete']);
    }
}
