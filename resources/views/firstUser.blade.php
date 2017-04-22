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
            <div class="pull-left df-logo"><a href="/"><img src="/img/logo-navbar-194x42.png"></a></div>
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
        <div id="error-container" class="alert alert-error center">
            @if (count($errors) > 0)
                <div class="alert alert-danger" style="margin-top:40px">
                    <strong>Whoops!</strong> There were some problems with your input.<br><br>
                    <ul>
                        @foreach ($errors as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif
        </div>

            <div class="box-wrapper">
                <form role="form" method="POST" action="{{ url('/setup') }}">
                    <div id="formbox" class="form-light boxed drop-shadow lifted">
                        <h2 class="inset">Create a System Admin User</h2>

                        <p>
                            Your DreamFactory instance requires at least one system administrator.
                            Complete this form to create your first admin user.
                            More users can be easily added using the 'Admin' application.
                        </p>

                        <div class="form-group">
                            <label for="username" class="sr-only">Username</label>

                            <div class="input-group">
                                <span class="input-group-addon bg_dg"><i class="fa fa-user fa-fw"></i></span>

                                <input tabindex="1"
                                       class="form-control username"
                                       autofocus
                                       type="text"
                                       id="username"
                                       name="username" placeholder="{{ $username_placeholder }}"
                                       value="{{ $username }}" />
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="email" class="sr-only">Email Address</label>

                            <div class="input-group">
                                <span class="input-group-addon bg_dg"><i class="fa fa-envelope fa-fw"></i></span>

                                <input tabindex="1"
                                       class="form-control email required"
                                       autofocus
                                       type="email"
                                       id="email"
                                       name="email" placeholder="{{ $email_placeholder }}"
                                       value="{{ $email }}" />
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="password" class="sr-only">Password</label>

                            <div class="input-group">
                                <span class="input-group-addon bg_ly"><i class="fa fa-lock fa-fw"></i></span>

                                <input tabindex="2"
                                       class="form-control password required"
                                       type="password"
                                       id="password"
                                       name="password"
                                       placeholder="Password" />
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="passwordRepeat" class="sr-only">Verify Password</label>

                            <div class="input-group">
                                <span class="input-group-addon bg_ly"><i class="fa fa-check fa-fw"></i></span>

                                <input tabindex="3"
                                       class="form-control password required"
                                       type="password"
                                       id="passwordRepeat"
                                       name="password_confirmation"
                                       placeholder="Verify Password" />
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="firstName" class="sr-only">First Name</label>

                            <div class="input-group">
                                <span class="input-group-addon bg_dg"><i class="fa fa-user fa-fw"></i></span>

                                <input tabindex="4"
                                       class="form-control required"
                                       type="text" id="firstName"
                                       name="first_name"
                                       placeholder="First Name"
                                       value="{{ $first_name }}" />
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="lastName" class="sr-only">Last Name</label>

                            <div class="input-group">
                                <span class="input-group-addon bg_dg"><i class="fa fa-user fa-fw"></i></span>

                                <input tabindex="5"
                                       class="form-control required"
                                       type="text"
                                       id="lastName"
                                       name="last_name"
                                       placeholder="Last Name"
                                       value="{{ $last_name }}" />
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="displayName" class="sr-only">Display Name</label>

                            <div class="input-group">
                                <span class="input-group-addon bg_dg"><i class="fa fa-eye fa-fw"></i></span>

                                <input tabindex="6"
                                       class="form-control"
                                       type="text"
                                       id="displayName"
                                       name="name"
                                       placeholder="Display Name"
                                       value="{{ $name }}" />
                            </div>
                        </div>



                        <div class="form-buttons">
                            <button type="submit" tabindex="7" class="btn btn-success pull-right">Create</button>
                        </div>

                    </div>
                </form>
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
</body>
</html>