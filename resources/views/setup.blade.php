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
    <link rel="shortcut icon" href="/img/df-icon-256x256.png" />

    <!-- Bootstrap 3 CSS -->
    <link rel="stylesheet"
          href="//netdna.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">

    <!-- Font Awesome -->
    <link rel="stylesheet"
          href="//netdna.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">

    <!-- DSP UI Styles & Code -->
    <link rel="stylesheet" href="/css/df.main.css">

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
</head>
<body>

<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
    <div class="container-fluid df-navbar">
        <div class="navbar-header">
            <div class="pull-left df-logo"><img src="/img/logo-navbar-194x42.png"></div>
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#main-nav">
                <span class="sr-only">Toggle navigation</span> <span class="icon-bar"></span> <span
                        class="icon-bar"></span> <span class="icon-bar"></span>
            </button>
        </div>

        <div id="navbar-container"></div>
    </div>
</div>

<div id="page-content">
    <div class="container-fluid container-inner">
        <div class="alert center">
            <div id="loadingFrame" class="alert center alert-warning" style="margin-top:40px; width: 500px">
                <span style="font-size: 18pt;: center">Hello and Welcome to DreamFactory 2.0!</span><br><br>
                <div id="loadingMsg" style="display: none;">
                    You will be up and ready in just few seconds.
                    Please wait while we setup and configure your DreamFactory instance.
                    <br>
                    <br>
                    <i>Please do not hit the back or refresh button while you wait here!</i>
                    <br><hr>
                </div>
            </div>
            <div id="errorFrame" class="alert center alert-danger" style="margin-top:40px; width: 800px; display: none">
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
                <a href="https://github.com/dreamfactorysoftware/dsp-core/"
                   target="_blank">v{{$version}}</a>
            </p></span>
    </div>
</div>




<!-- Scripts -->
<script src="//netdna.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
<script>

    setTimeout(function(){
        $.ajax({
            url: '/setup_db',
            async: true,
            type: 'POST',
            dataType: 'json',
            contentType: 'application/json',
            cache: false,
            processData: false,
            //data: JSON.stringify(data),
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
