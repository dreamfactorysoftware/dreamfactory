@extends('emails.layout')
{{--

 This is an email blade for resetting password

 The following view data is required:

 $contentHeader       The callout/header of the email's body
 $firstName           The name of the recipient.
 $link                The password reset link.
 $code                The reset code.
 $appName             Name of the application.

--}}
@section('contentBody')
    <div style="padding: 10px;">
        <p>
            Hi {{ $first_name }},
        </p>

        <div>
            You have registered a user account on {{ $app_name }}. Go to the following url, enter the code below, and set your password to confirm your account.<br/>
            <br/>
            {{ $link }}
            <br/><br/>
            Confirmation Code: {{ $confirm_code }}<br/>
        </div>

        <p>
            <cite>-- The Dream Team</cite>
        </p>
    </div>
@stop