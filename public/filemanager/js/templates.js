/**
 * Created with JetBrains PhpStorm.
 * User: jasonsykes
 * Date: 1/7/13
 * Time: 11:37 AM
 * To change this template use File | Settings | File Templates.
 */
var Templates = {
    thumbPanel : "<h1>{{name}}</h1><br/>{{desc}}",
    alertMessage :'<div class="alert">' +
        '<a class="close" data-dismiss="alert">x</a>' +
        '{{message}}' +
        '</div>',
    gridTemplate :'<table id="db-tables" class="table table-bordered table-striped">' +
        '<thead>' +
        '<tr>' +
        '<th class="table-names-header">Table Name</th>' +
        '</tr>' +
        '</thead>' +
        '<tbody>' +
        '{{#table}}' +
        '<tr>' +
        '<td onclick = "Actions.loadSchema(\'{{name}}\')")>{{name}}</td>' +
        '</tr> ' +
        '{{/table}}' +
        '</tbody>' +
        '</table>',
    appTemplate : '<table id="db-tables" class="table table-bordered table-striped">' +
        '<thead>' +
        '<tr>' +
        '<th class="table-names-header">Applications</th>' +
        '</tr>' +
        '</thead>' +
        '<tbody>' +
        '{{#record}}' +
        '<tr>' +
        '<td>{{fields.label}}</td>' +
        '</tr> ' +
        '{{/record}}' +
        '</tbody>' +
        '</table>',
    navBarDropDownTemplate:'<ul class="nav">' +
        '<li class="dropdown">' +
        '<a data-target="#" href="#" class="dropdown-toggle" data-toggle="dropdown">' +
        'Applications' +
        ' <b class="caret"></b>' +
        '</a>' +
        '<ul class="dropdown-menu">' +

        '{{#Applications.app_groups}}' +
        '<li>&nbsp;&nbsp;&nbsp;{{name}}</li>' +
        '{{#apps}}' +
        '<li><a data-target="#" href="#" onclick = "Actions.showApp(\'{{api_name}}\',\'{{launch_url}}\',\'{{is_url_external}}\',{{requires_fullscreen}})">{{name}}</a></li>' +
        '{{/apps}}' +

        '{{/Applications.app_groups}}' +

        '{{#Applications.no_group_apps}}' +
        '<li class="no_group"><a data-target="#" href="#" onclick = "Actions.showApp(\'{{api_name}}\',\'{{launch_url}}\',\'{{is_url_external}}\',{{requires_fullscreen}})">&nbsp;&nbsp;&nbsp;{{name}}</a></li>' +
        '{{/Applications.no_group_apps}}' +
        '</ul>' +
        '</li>' +
        '</ul>',
    userInfoTemplate : '<div class="btn-group"><a onclick="Actions.doProfileDialog()" id="dfProfileLnk" class="btn btn-inverse" title="Change Your Profile">' +
        '<i class="icon-user"></i>&nbsp;{{display_name}}</a><a id="dfPasswordLnk" onclick="Actions.doChangePasswordDialog()" class="btn btn-inverse" title="Change Your Password"><i class="icon-key"></i></a>' +
        '<a id="fs_toggle" onclick="Actions.toggleFullScreen(true)" class="btn btn-inverse" title="Full Screen" ><i class="icon-resize-full"></i></a><a id="dfSignOutLink" onclick="Actions.doSignOutDialog()" class="btn btn-inverse" title="End Your Session Now"><i class="icon-signout"></i></a></div>',
    appIconTemplate : '{{#Applications.app_groups}}<h3>{{name}}</h3>' +
        '<table class="table is_grouped">' +
        '{{#apps}}' +
        '<tr><td><div class="media" style="margin:0px;" onclick = "Actions.showApp(\'{{api_name}}\',\'{{launch_url}}\',\'{{is_url_external}}\',{{requires_fullscreen}})">' +
        '<span class=" well well-small pull-left" data-target="#" href="#">' +
        '<i class="icon-cloud icon-2x"></i>' +
        '</span>' +
        '<div class="media-body">' +
        '<h4 class="media-heading">{{name}}</h4>' +
        '{{description}}' +
        '</div>' +
        '</div></td></tr>' +
        '{{/apps}}</table>' +
        '{{/Applications.app_groups}}<table class="table">' +
        '{{#Applications.no_group_apps}}' +
        '<tr><td><div class="media" style="margin:0px;" onclick = "Actions.showApp(\'{{api_name}}\',\'{{launch_url}}\',\'{{is_url_external}}\',{{requires_fullscreen}})">' +
        '<span class=" well well-small warning pull-left" data-target="#" href="#">' +
        '<i class="icon-cloud icon-2x"></i>' +
        '</span>' +
        '<div class="media-body">' +
        '<h4 class="media-heading">{{name}}</h4>' +
        '{{description}}' +
        '</div>' +
        '</div></td></tr>' +
        '{{/Applications.no_group_apps}}</table>',
    navBarTemplate : ' <div class="pull-right" id="dfControl1" data-ng-if="true !== user.activeSession">' +
        ' <a class="btn btn-primary" onclick="Actions.doSignInDialog()"><li class="icon-signin"></li>&nbsp;Sign In</a>' +
        ' {{#allow_open_registration}}<a class="btn btn-primary" onclick="Actions.createAccount()"><li class="icon-key"></li>&nbsp;Create Account</a>{{/allow_open_registration}}' +
        '</div>',
    errorTemplate : '{{#error}}<div class="alert">' +
        '<button type="button" class="close" data-dismiss="alert">x</button>' +
        '<strong>{{message}}</strong>' +
        '</div>{{/error}}',
    loadTemplate : function (template, data, renderTo) {
        var processTpl;
        processTpl = Mustache.to_html(template, data);
        $('#' + renderTo).html(processTpl);

    }
};
