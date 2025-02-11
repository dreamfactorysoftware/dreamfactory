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
  <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">

  <!-- Font Awesome -->
  <link rel="stylesheet" href="//netdna.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">

  <!-- DSP UI Styles & Code -->
  <link rel="stylesheet" href="/css/df-create-first-user.css">

    <script src="//ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>

<body>

  <div id="page-content" class="first-user">
    <div class="container-fluid container-inner">
      <div id="error-container">
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
          @csrf
          <div id="formbox" class="form-light boxed drop-shadow lifted">
            <h2 class="inset">Create a System Administrator</h2>

            <p>
              Complete this form to create your first administrator. Additional administrators can be added using the
              'Admin' application.
            </p>

            <p class="required-fields-info"><span>*</span> required fields</p>

            <div class="form-group">
              <label for="username">Username</label>
              <input tabindex="1" class="form-control username" autofocus type="text" id="username" name="username"
                placeholder="{{ $username_placeholder }}" value="{{ $username }}" />
            </div>
            <div class="form-group required">
              <label for="email">Email Address</label>
              <input tabindex="1" class="form-control email" autofocus type="email" id="email" name="email"
                placeholder="{{ $email_placeholder }}" value="{{ $email }}" required />
            </div>
            <div class="form-group required">
              <label for="phone">Phone Number</label>
              <input tabindex=1" class="form-control phone" autofocus type="tel" id="phone" name="phone"
                placeholder="Phone" value="{{ $phone  }}" required />
            </div>
            <div class="form-group required">
              <label for="password">Password</label>
              <input tabindex="2" class="form-control password" type="password" id="password" name="password"
                placeholder="Password" required />
            </div>
            <div class="form-group required">
              <label for="passwordRepeat">Verify Password</label>
              <input tabindex="3" class="form-control password" type="password" id="passwordRepeat"
                name="password_confirmation" placeholder="Verify Password" required />
            </div>
            <div class="form-group required">
              <label for="firstName">First Name</label>
              <input tabindex="4" class="form-control" type="text" id="firstName" name="first_name"
                placeholder="First Name" value="{{ $first_name }}" required />
            </div>
            <div class="form-group required">
              <label for="lastName">Last Name</label>
              <input tabindex="5" class="form-control" type="text" id="lastName" name="last_name"
                placeholder="Last Name" value="{{ $last_name }}" required />
            </div>
            <div class="form-group">
              <label for="displayName">Display Name</label>
              <input tabindex="6" class="form-control" type="text" id="displayName" name="name"
                placeholder="Display Name" value="{{ $name }}" />
            </div>

            <div class="form-buttons">
              <button type="submit" tabindex="7" class="btn btn-success">Create</button>
            </div>

          </div>
        </form>
      </div>
    </div>
  </div>

  <div id="footer">
    <div class="container-fluid">
      <span class="pull-left dsp-footer-copyright">
        <p class="footer-text">&copy; <a target="_blank" href="https://www.dreamfactory.com">DreamFactory Software,
            Inc.</a> 2015-<?php echo date(
                        'Y'
                ); ?>. All Rights Reserved.
        </p>
      </span> <span class="pull-right dsp-footer-version">
        <p class="footer-text">
          <a href="https://github.com/dreamfactorysoftware/dreamfactory/" target="_blank">v{{$version}}</a>
        </p>
      </span>
    </div>
  </div>




  <!-- Scripts -->
  <script src="//netdna.bootstrapcdn.com/bootstrap/5.3.3/js/bootstrap.min.js"></script>
</body>

</html>
