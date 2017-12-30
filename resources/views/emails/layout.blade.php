<!DOCTYPE html>
<html lang="en">
<head>
    <title>DreamFactory Instance&trade;</title>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <meta name="language" content="en" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="HandheldFriendly" content="true" />
    <link rel="shortcut icon" href="//www.dreamfactory.com/favicon.ico" />
    <style type="text/css">
        @import url(http://fonts.googleapis.com/css?family=Open+Sans|Roboto);

        body, table, p {
            font-family: Roboto, "Open Sans", Helvetica, Arial, sans-serif;
        }

        body {
            background-color: #dfdfdf;
            padding:          5px;
            width:            100%;
            margin:           0 auto;
        }

        table {
            border:           0;
            padding:          0;
            margin:           0;
            font-family:      Roboto, "Open Sans", Helvetica, Arial, sans-serif;
            background-color: #dfdfdf;
            border-radius:    4px;
        }

        table table {
            background-color: #ffffff;
            margin:           0;
            padding:          0;
            text-align:       left;
        }

        .content-body {
            padding: 15px 15px 10px;
            margin:  0;
        }

        .content-header {
            border-bottom: 1px solid #ddd;
            padding:       10px 0 5px;
            margin:        0 10px;
        }
    </style>
</head>
<body style="background-color:#DFDFDF; padding:5px; margin: 0 auto; width:100%;">
<table border="0"
       cellspacing="0"
       cellpadding="0"
       style="width:600px !important; font-family: Roboto, 'Open Sans', Helvetica, Arial, sans-serif; margin:0 auto; padding:0;"
       width="600">
    <tbody>
    <tr>
        <td align="left" valign="middle" style="margin: 10px 0; padding: 10px 0 15px;">
            <a style="text-decoration:none; cursor:pointer; border:none; display:block; height:29px; width:100%;"
               target="_blank"
               href="//dreamfactory.com">
                <img src="http://dreamfactory.com/images/email-logo-215x29.png"
                                                              width="215"
                                                              height="29"
                                                              alt="DreamFactory"
                                                              style="border:none;text-decoration:none;" />
            </a>
        </td>
    </tr>
    </tbody>
</table>

<table cellspacing="0"
       cellpadding="0"
       style="border-radius: 4px; background-color: #ffffff; font-family:Roboto,'Open Sans',Helvetica,Arial,sans-serif; margin: 0 auto; border: 1px solid #ccc;"
       width="600"
       bgcolor="#FFFFFF">
    <tbody>
    <tr>
        <td style="padding:0;margin:0;" align="left">
            <table
                    cellspacing="0"
                    cellpadding="0"
                    style="font-family:Roboto,'Open Sans',Helvetica,Arial,sans-serif; "
                    width="100%">
                <tbody>
                <tr>
                    <td style="font-family:Roboto,'Open Sans',Helvetica,Arial,sans-serif;color:#333333;">
                        <h2 class="content-header">{{ $content_header }}</h2>
                    </td>
                </tr>
                <tr>
                    <td style="font-family:Roboto,'Open Sans',Helvetica,Arial,sans-serif;color:#333333;">
                        <div class="content-body">
                            @yield('contentBody')
                        </div>
                    </td>
                </tr>
                </tbody>
            </table>
        </td>
    </tr>
    </tbody>
</table>

<table border="0"
       cellspacing="0"
       cellpadding="0"
       style="font-family:Roboto,'Open Sans',Helvetica,Arial,sans-serif; margin: 10px auto 0; padding: 0;"
       width="600"
       class="responsive">
    <tbody>
    <tr>
        <td style="font-size: 8pt;color: #aaa; padding: 0 5px;">
            <p>
                You received this email because you used a <a href="//www.dreamfactory.com/" alt target="_blank">DreamFactory
                    Instance&trade;</a>. This system will never use your email address other than to communicate with you about your
                system usage.
            </p>

            <p>If you need further assistance or have questions, please email <a
                        style="color:#0077B5;text-decoration:none;"
                        target="_blank"
                        href="mailto:dspsupport@dreamfactory.com">DreamFactory Support</a>.</p>
        </td>
    </tr>
    </tbody>
</table>

</body>
</html>