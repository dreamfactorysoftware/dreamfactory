@extends('emails.layout')
{{--

 This is a generic blade for generating emails.

 The following view data is required:

 $first_name           The first name of the recipient
 $content_header       The callout/header of the email's body
 $email_body            The actual guts of the email

--}}
@section('contentBody')
    <div style="padding: 10px;">
        <p>
            {{ $first_name }},
        </p>

        <div>
            {{-- Unescaped: email_body comes from admin-configured templates (system/email_template). --}}
            {{-- Only system admins can create/edit templates, so this is trusted content. --}}
            {!! $email_body !!}
        </div>

        <p>
            <cite>-- The Dream Team</cite>
        </p>
    </div>
@stop
