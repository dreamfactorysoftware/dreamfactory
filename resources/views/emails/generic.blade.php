@extends('emails.layout')
{{--

 This is a generic blade for generating emails.

 The following view data is required:

 $firstName           The first name of the recipient
 $contentHeader       The callout/header of the email's body
 $emailBody           The actual guts of the email

--}}
@section('contentBody')
    <div style="padding: 10px;">
        <p>
            {{ $firstName }},
        </p>

        <div>
            {!! $emailBody !!}
        </div>

        <p>
            <cite>-- The Dream Team</cite>
        </p>
    </div>
@stop
