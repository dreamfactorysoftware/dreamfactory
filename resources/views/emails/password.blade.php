@extends('emails.layout')
{{--

 This is an email blade for resetting password

 The following view data is required:

 $contentHeader       The callout/header of the email's body
 $firstName                The name of the recipient.
 $link                The password reset link
 $code                The reset code

--}}
@section('contentBody')
    <div style="padding: 10px;">
        <p>
            Hi {{ $first_name }},
        </p>

        <div>
            You have requested to reset your password. Go to the following url, enter the code below, and set your new password.
            <br><br>
            {{ $link }}
            <br><br>
            Confirmation Code: {{ $confirm_code }}
        </div>

        <p>
            <cite>-- The Dream Team</cite>
        </p>
    </div>
@stop
