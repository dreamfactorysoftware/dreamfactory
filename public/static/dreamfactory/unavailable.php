<!DOCTYPE html>
<html lang="en">
<head>
    <title>DreamFactory Services Platform&trade;</title>
    <meta name="page-route" content="web/index" />

    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, user-scalable=yes, initial-scale=1.0">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="author" content="DreamFactory Software, Inc.">
    <meta name="language" content="en" />
    <link rel="shortcut icon" href="/img/df_logo_factory-32x32.png" />

    <!-- Bootstrap 3 CSS -->
    <link rel="stylesheet"
          href="//netdna.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">

    <!-- Font Awesome -->
    <link rel="stylesheet"
          href="//netdna.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">

    <!-- DSP UI Styles & Code -->
    <link rel="stylesheet" href="/css/dsp.main.css">
    <link rel="stylesheet" href="/css/maintenance.css">

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
</head>
<body class="maintenance-page">

<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
    <div class="container-fluid df-navbar">
        <div class="navbar-header">
            <div class="pull-left df-logo"><a href="/"><img src="/img/logo-navbar-194x42.png"></a></div>
            <!--            <span class="pull-left df-logo"><a href="/"><img src="/img/df-apple-touch-icon.png"></a></span>--><!--            <span class="pull-left df-brand"><span class="dream-orange">Dream</span>Factory</span>-->
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#main-nav">
                <span class="sr-only">Toggle navigation</span> <span class="icon-bar"></span> <span
                    class="icon-bar"></span> <span class="icon-bar"></span>
            </button>
        </div>

        <div id="navbar-container"></div>
    </div>
</div>

<div class="container-fluid maintenance">
    <div class="jumbotron">
        <h1><i class="fa fa-exclamation-circle text-danger"></i> Platform Offline </h1>

        <p>This system is currently offline. Please check with your system administrator regarding its status.</p>
    </div>
</div>

<div id="footer">
    <div class="container-fluid">
        <span class="pull-left dsp-footer-copyright">
            <p class="footer-text">&copy; <a target="_blank" href="https://www.dreamfactory.com">DreamFactory Software, Inc.</a> 2012-<?php echo date(
                    'Y'
                ); ?>. All Rights Reserved.
            </p>
        </span> <span class="pull-right dsp-footer-version"><p class="footer-text">
                <a href="https://github.com/dreamfactorysoftware/dsp-core/"
                   target="_blank">v<?php echo DSP_VERSION; ?></a>
            </p></span>
    </div>
</div>

<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
</body>
</html>
