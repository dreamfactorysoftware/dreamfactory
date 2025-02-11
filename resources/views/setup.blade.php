<!DOCTYPE html>
<html lang="en">
<head>
    <title>DreamFactory&trade;</title>
    <meta name="page-route" content="web/index" />

    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, user-scalable=yes, initial-scale=1.0">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="author" content="DreamFactory Software, Inc.">
    <meta name="language" content="en" />
    <link rel="shortcut icon" href="/img/favicon.png" />

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700;900&family=Open+Sans:wght@300;400;700&display=swap" rel="stylesheet">

    <!-- Bootstrap 3 CSS -->
    <link rel="stylesheet"
          href="//netdna.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">

    <!-- Font Awesome -->
    <link rel="stylesheet"
          href="//netdna.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">

    <!-- DSP UI Styles & Code -->
    <link rel="stylesheet" href="/css/df-create-first-user.css">

    <script src="//ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

    <!-- Add this meta tag right after other meta tags -->
    <meta name="csrf-token" content="{{ csrf_token() }}">
</head>
<body>

<div class="df-logo"><img src="/img/df-logo.png" height="40px" width="263" alt="DreamFactory"></div>

<div id="page-content">
    <div class="container-fluid container-inner">
        <div id="error-container">
            <div id="loadingFrame" class="box-wrapper">
                <h3>Hello and Welcome to DreamFactory v{{$version}}!</h3>
                <div id="loadingMsg" style="display: none;">
                    You will be up and running in just few seconds.
                    Please wait while we setup and configure your DreamFactory instance.
                    <br>
                    <br>
                    <b>Please do not hit the back or refresh button while you wait here!</b>
                    <br><hr>
                </div>
            </div>
            <div id="errorFrame" class="alert center alert-danger" style="display: none">
                <span style="font-size: 14pt;">Installation failed. Please run the migration and seeder manually.</span><hr>
                <div id="errorMsg"></div>
            </div>
        </div>
    </div>
</div>
</div>

<div id="footer">
    <div class="container-fluid">
        <span class="pull-left dsp-footer-copyright">
            <p class="footer-text">&copy; <a target="_blank" href="https://www.dreamfactory.com">DreamFactory Software, Inc.</a> 2015-<?php echo date(
                        'Y'
                ); ?>. All Rights Reserved.
            </p>
        </span> <span class="pull-right dsp-footer-version"><p class="footer-text">
                <a href="https://github.com/dreamfactorysoftware/dreamfactory/"
                   target="_blank">v{{$version}}</a>
            </p></span>
    </div>
</div>




<!-- Scripts -->
<script src="//netdna.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
<script>
    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
        }
    });

    setTimeout(function(){
        $.ajax({
            url: '/setup_db',
            async: true,
            type: 'POST',
            dataType: 'json',
            contentType: 'application/json',
            cache: false,
            processData: false,
            data: JSON.stringify({}),  // Add empty data object
            beforeSend: function (xhr) {
                $('#loadingMsg').slideDown();
            },
            success: function (json) {
                if(json.success){
                    location.href=json.redirect_path;
                } else {
                    $('#loadingFrame').slideUp();
                    $('#errorMsg').html(json.message);
                    $('#errorFrame').slideDown();
                    console.log(json)
                }
            },
            error: function (err) {
                $('#loadingFrame').slideUp();
                $('#errorMsg').html(err.responseText);
                $('#errorFrame').slideDown();
                console.log(err)
            }
        });
    }, 2000);
</script>
</body>
</html>
