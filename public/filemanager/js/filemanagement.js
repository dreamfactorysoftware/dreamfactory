var currentPath = null;
var apiKey = "b5cb82af7b5d4130f36149f90aa2746782e59a872ac70454ac188743cb55b0ba";


// setup

$(document).ready(function () {

    $(document).ajaxStart($.blockUI).ajaxStop($.unblockUI);

    $('#dndPanel').bind('dragover', handleDragOver).bind('drop', handleFileSelect);

    resizeUi();

    $('#editPanel').hide();
    $('#fileControl').hide();

    $("#errorDialog").dialog({
        resizable: false,
        modal: true,
        autoOpen: false,
        closeOnEscape: true,
        buttons: {}
    });

    $("#mkdir").click(function () {
        if ($(this).hasClass("disabled")) {
            return false;
        }
        var name = prompt("Enter name for new folder");
        if (name) {
            createFolder(currentPath, name);
        }
    });

    $("#importfile").click(function () {
        if ($(this).hasClass("disabled")) {
            return false;
        }
        $('#fileModal').modal('toggle');
    });

    $("#exportzip").click(function () {
        if ($(this).hasClass("disabled")) {
            return false;
        }
        $("#fileIframe").attr("src", "/api/v2" + currentPath + "?zip=true&api_key=" + apiKey + "&session_token=" + sessionToken);
    });

    $("#rm").click(function () {

        if ($(this).hasClass("disabled")) {
            return false;
        }
        deleteSelected();
    });

    $("#exitEditor").button({icons: {primary: "ui-icon-close"}}).click(function () {
        $('#editPanel').hide();
        $('#fileControl').hide();
        $('#browserControl').show();
        $('#dndPanel').show();
    });

    $("#importExtract").click(function () {
        if ($(this).prop("checked")) {
            $("#importReplace").removeAttr("disabled");
        } else {
            $("#importReplace").attr("disabled", "disabled");
        }
    });

    $("#home").click(function () {
        loadRootFolder();
    });

    loadRootFolder();
});

// Session inherited from query parameter, iframe, or opener
function getSessionToken() {
    var phpSessionId = CommonUtilities.getQueryParameter('session_token');
    if (phpSessionId)
        return phpSessionId;

    phpSessionId = parent.document.cookie.match(/PHPSESSID=[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\;/i);

    if ((phpSessionId == null) && (window.opener))
        phpSessionId = window.opener.document.cookie.match(/PHPSESSID=[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\;/i);

    if (phpSessionId == null)
        return '';

    if (typeof(phpSessionId) == 'undefined')
        return '';

    if (phpSessionId.length <= 0)
        return '';

    phpSessionId = phpSessionId[0];

    var end = phpSessionId.lastIndexOf(';');
    if (end == -1) end = phpSessionId.length;

    return phpSessionId.substring(10, end);
}

var sessionToken = getSessionToken();


// UI Building

function printLocation(path) {
    var display = '';
    if (path && path != '') {
        var builder = '/';
        display = '/';
        var allowroot = CommonUtilities.getQueryParameter('allowroot');
        var tmp = path.split('/');
        for (var i in tmp) {
            if (tmp[i].length > 0) {
                if (builder == '/') {
                    if (allowroot == 'false') {
                        builder += tmp[i] + '/';
                        continue;
                    }
                }
                builder += tmp[i] + '/';
                display += '<a href="javascript: loadFolder(\'' + builder + '\')">' + tmp[i] + '</a>/';
            }
        }
    }
    // remove trailing slashes
    if (display != '/') {
        display = display.replace(/\/+$/, "");
    }
    $('#breadcrumbs').html(display);
}

function getIcon(file) {

    switch (file.contentType) {

        case "image/x-ms-bmp":
            return "gfx/file-bmp.png";
        case "text/html":
            return "gfx/file-htm.png";
        case "text/css":
            return "gfx/file-css.png";
        case "text/javascript":
            return "gfx/file-js.png";
        case "application/javascript":
            return "gfx/file-js.png";
        case "text/js":
            return "gfx/file-js.png";
        case "image/jpeg":
            return "gfx/file-jpg.png";
        case "image/gif":
            return "gfx/file-gif.png";
        case "text/plain":
        case "image/x-icon":
        case "application/octet-stream":
        default:
            return "gfx/file.png";
    }
}

function buildItem(path, icon, name, type, editor, extra) {

    return '<div class="fmObject" data-target="' + path + '" data-type="' + type + '">' +
        (editor ? editor : '') +
        '<div class="cLeft fm_icon" align="center"><img src="' + icon + '" border="0"/></div>' +
        '<div class="cLeft cW30"><span class="fm_label">' + name + '</span></div>' +
        (extra ? extra : '') +
        '<div class="cClear"><!-- --></div>' +
        '</div>';
}

function allowEdit(mime) {

    return true;
}

function buildEditor(mime, path) {


    if (allowEdit(mime)) {
        return '<a href="#" class="btn btn-small fmSquareButton cRight download_file" data-mime="' + mime + '" data-path="' + path + '"><i class="fa fa-download"></i></a><a href="#" class="btn btn-small fmSquareButton cRight editor" data-mime="' + mime + '" data-path="' + path + '"><i class="fa fa-pencil"></i></a>';
    }
    return '';
}

function buildFolderControl(path) {

    return '<a href="#" class="btn btn-small fmSquareButton cRight" data-path="' + path + '"><i class="fa fa-folder-open"></i></a>';
}

function buildListingUI(json, svc) {

    var html = '';
    if (json.resource) {
        for (var i in json.resource) {
            var name = json.resource[i].name;
            var path = json.resource[i].path;
            switch (json.resource[i].type) {
                case 'service':
                    if (svc != '') {
                        path = svc + '/' + path;
                    }
                    path = '/' + path;
                    var ctrl = buildFolderControl(path);
                    if (currentPath == '/') {
                        var icon = 'gfx/service.png';
                    } else {
                        var icon = 'gfx/folder-horizontal-open.png';
                    }
                    html += buildItem(path, icon, name, 'folder', ctrl);
                    break;
                case 'folder':
                    if (svc != '') {
                        path = svc + '/' + path;
                    }
                    path = '/' + path;
                    var ctrl = buildFolderControl(path);
                    if (currentPath == '/') {
                        var icon = 'gfx/service.png';
                    } else {
                        var icon = 'gfx/folder-horizontal-open.png';
                    }
                    html += buildItem(path, icon, name, 'folder', ctrl);
                    break;
                case 'file':
                    if (svc != '') {
                        path = svc + '/' + path;
                    }
                    path = '/' + path;
                    var editor = buildEditor(json.resource[i].contentType, path);
                    var extra = '<div class="cLeft cW5">&nbsp;</div>';
                    if (json.resource[i].lastModified) {
                        extra += '<div class="cLeft cW20 fm_label">' + json.resource[i].lastModified + '</div>';
                    }
                    if (json.resource[i].contentType) {
                        extra += '<div class="cLeft cW15 fm_label">' + json.resource[i].contentType + '</div>';
                    }
                    if (json.resource[i].size) {
                        extra += '<div class="cLeft cW10 fm_label">' + json.resource[i].size + ' bytes</div>';
                    }
                    html += buildItem(path, getIcon(json.resource[i]), json.resource[i].name, 'file', editor, extra);
                    break;
            }
        }
    }

    $('#listing').html(html);

    $('.editor').click(function () {
        var path = $(this).data('path');
        var mime = $(this).data('mime');
        var w = window.open('editor.html?path=' + path + '&mime=' + mime + '&api_key=' + apiKey + '&session_token=' + sessionToken,
            path + " " + mime,
            'width=800,height=400,toolbars=no,statusbar=no,resizable=no'
        );
        w.focus();
        return false;
    });
    $('.download_file').click(function () {
        var target = $(this).data('path');

        window.location.href = CurrentServer + '/api/v2' + target + "?api_key=" + apiKey + "&session_token=" + sessionToken + "&download=true";

    });
    $('.folder_open').click(function () {
        loadFolder($(this).data('path'));
        return false;
    });

    $('.fmObject').click(function (e) {
        var t = $(this);
        var unselect = t.hasClass('highlighted');
        if (!e.ctrlKey) {
            $('.fmObject').each(function () {
                $(this).removeClass('highlighted');
            });
        }
        if (t.hasClass('highlighted')) {
            t.removeClass('highlighted');
        } else if (!unselect) {
            t.addClass('ui-corner-all');
            t.addClass('highlighted');
        }
        document.getSelection().removeAllRanges();
        updateButtons();
    }).dblclick(function () {


        var target = $(this).data('target');
        var type = $(this).data('type');
        if (type == 'folder') {
            loadFolder(target);
        } else {

            var path = target;
            var mime = null;
            //var mime = $(this).data('mime');

            var w = window.open('editor.html?path=' + path + '&mime=' + mime + '&api_key=' + apiKey + '&session_token=' + sessionToken,
                path + " " + mime,
                'width=800,height=400,toolbars=no,statusbar=no,resizable=no'
            );
            w.focus();
            return false;
        }
    });

    $('.fmObject').bind('dragover', handleDragOver).bind('drop', handleFileSelect);
}

function updateButtons() {
    if (currentPath == '/') {
        $('#mkdir').addClass("disabled");
        $('#importfile').addClass("disabled");
        $('#exportzip').addClass("disabled");
    } else {
        $('#mkdir').removeClass("disabled");
        $('#importfile').removeClass("disabled");
        $('#exportzip').removeClass("disabled");
    }
    if (currentPath == '/' || countSelectedItems() == 0) {
        $('#rm').addClass("disabled");
    } else {
        $('#rm').removeClass("disabled");
    }

}

// drag and drop

// May be a better way to do this...

function processEvent(e) {

    e.originalEvent.stopPropagation();
    e.originalEvent.preventDefault();
    return e.originalEvent;
}

function handleDragOver(evt) {

    var e = processEvent(evt);
    e.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
}

function handleFileSelect(evt) {

    var e = processEvent(evt);
    var target = $(e.currentTarget).data('target');
    var type = $(e.currentTarget).data('type');
    if (target == '') {
        target = currentPath;
    }
    if (target == '/' || target == '/app/') {
        alert("This location is not writable.");
        return;
    }
    var dropFiles = e.dataTransfer.files;
    if (dropFiles === undefined) {
        alert("Drag and drop of files is not yet supported by this browser.");
        return;
    }
    var skipped = 0;
    for (var i = 0; i < dropFiles.length; i++) {
        // try to skip folders
        if (dropFiles[i].size == 0) {
            skipped++;
            continue;
        }
        createFile(target, dropFiles[i]);
    }
    if (skipped) {
        alert("Drag and drop is currently for files only. Folders and empty files are not uploaded.");
    }
}

// API calls

function loadRootFolder() {

    var path = CommonUtilities.getQueryParameter('path');

    if ((path == null) || (path == ''))
        path = '/';

    loadFolder(path);
}

function reloadFolder() {

    loadFolder(currentPath);
}

function loadFolder(path) {

    if (path == '/') {
        $.ajax({
            headers: {
                "X-DreamFactory-API-Key": apiKey,
                "X-DreamFactory-Session-Token": sessionToken
            },
            dataType: 'json',
            url: CurrentServer + '/api/v2/system/service',
            data: "fields=name&filter=" + escape("type='local_file' or type='aws_s3' or type='azure_blob' or type='rackspace_cloud_files'"),
            cache: false,
            success: function (response) {
                try {
                    document.getSelection().removeAllRanges();
                } catch (e) {/* silent! */
                }
                ;
                currentPath = path;
                printLocation(path);
                var json = {"resource": []};
                if (response.resource) {
                    for (var i in response.resource) {
                        json.resource.push({
                            "name": response.resource[i].name,
                            "path": response.resource[i].name + '/',
                            "type": 'service',
                        });
                    }
                }
                buildListingUI(json, '');
                updateButtons();
            },
            error: function (response) {
                alertErr(response);
            }
        });
    } else {
        $.ajax({
            headers: {
                "X-DreamFactory-API-Key": apiKey,
                "X-DreamFactory-Session-Token": sessionToken
            },
            dataType: 'json',
            url: CurrentServer + '/api/v2' + path,
            data: '',
            cache: false,
            success: function (response) {
                try {
                    document.getSelection().removeAllRanges();
                } catch (e) {/* silent! */
                }
                currentPath = path;
                printLocation(path);
                var tmp = path.split('/');
                buildListingUI(response, tmp[1]);
                updateButtons();
            },
            error: function (response) {
                alertErr(response);
            }
        });
    }
}

function createFile(target, file) {

    var extra = '';
    if (file.name.substr(file.name.length - 4) == '.zip') {
        if (confirm("Do you want to expand " + file.name + " on upload?")) {
            extra = '&extract=true';
        }
    } else {
        var exists = false;
        $(".fmObject").each(function () {
            if ($(this).data("target") == currentPath + file.name) {
                exists = true;
            }
        });
        if (exists) {
            if (!confirm("Do you want to overwrite " + file.name + " on upload?")) {
                return;
            }
        }
    }
    var data = null;
    if (file.raw) {
        data = file.raw;
    } else {
        data = file;
    }
    $.ajax({
        headers: {
            "X-DreamFactory-API-Key": apiKey,
            "X-DreamFactory-Session-Token": sessionToken
        },
        beforeSend: function (request) {
            request.setRequestHeader("X-File-Name", file.name);
            request.setRequestHeader("Content-Type", file.type);
        },
        dataType: 'json',
        type: 'POST',
        url: CurrentServer + '/api/v2' + target + '?' + extra,
        data: data,
        cache: false,
        processData: false,
        success: function (response) {
            loadFolder(target);
        },
        error: function (response) {
            alertErr(response);
            loadFolder(target);
        }
    });
}

function createFolder(target, name) {

        $.ajax({
            headers: {
                "X-DreamFactory-API-Key": apiKey,
                "X-DreamFactory-Session-Token": sessionToken
            },
            beforeSend: function (request) {
                request.setRequestHeader("X-Folder-Name", name);
            },
            dataType: 'json',
            type: 'POST',
            url: CurrentServer + '/api/v2' + target,
            data: '',
            cache: false,
            processData: false,
            success: function (response) {
                loadFolder(target);
            },
            error: function (response) {
                alertErr(response);
                loadFolder(target);
            }
        });
}
function deleteSelected() {

    var sel = getSelectedItems();
    var folders = sel.folder;
    var files = sel.file;
    if ((folders && folders.length > 0) || (files && files.length > 0)) {
        var msg = "You are about to permanently delete the following;\n\n";
        if (folders.length > 0) {
            msg += "\t" + folders.length + " folders\n";
        }
        if (files.length > 0) {
            msg += "\t" + files.length + " files\n";
        }
        msg += "\nAre you sure you want to delete these selected items?";
        if (confirm(msg)) {
            var data = {};
            data.resource = [];
            if (folders.length > 0) {
                data.resource = data.resource.concat(folders);
            }
            if (files.length > 0) {
                data.resource = data.resource.concat(files);
            }
            data = JSON.stringify(data);
            $.ajax({
                headers: {
                    "X-DreamFactory-API-Key": apiKey,
                    "X-DreamFactory-Session-Token": sessionToken
                },
                beforeSend: function (request) {
                    request.setRequestHeader("X-HTTP-Method", 'DELETE');
                },
                dataType: 'json',
                type: 'POST',
                url: CurrentServer + '/api/v2' + currentPath + '?force=true',
                data: data,
                cache: false,
                processData: false,
                success: function (response) {
                    loadFolder(currentPath);
                },
                error: function (response) {
                    alertErr(response);
                    loadFolder(currentPath);
                }
            });
        }
    }
}

function errorHandler(errs, data) {
    var str = '';
    if (errs.length > 1) {
        'The following errors occured;\n';
        for (var i in errs) {
            str += '\n\t' + (i + 1) + '. ' + errs[i];
        }
    } else {
        str += 'The following error occured; ' + errs[0];
    }
    alert(str += "\n\n");
}

function getSelectedItems() {

    var folders = [];
    var files = [];
    $('.highlighted').each(function () {
        var target = $(this).data('target');
        var tmp = target.split('/');
        target = target.substring(2 + tmp[1].length);
        if ($(this).data('type') == 'folder') {
            folders.push({path: target, type: 'folder'});
        } else {
            files.push({path: target, type: 'file'});
        }
    });
    return {
        "folder": folders,
        "file": files
    };
}

function countSelectedItems() {

    var total = 0;
    var sel = getSelectedItems();
    var folders = sel.folder;
    var files = sel.file;
    if (folders) {
        total += folders.length;
    }
    if (files) {
        total += files.length;
    }
    return total;
}

// misc

function resizeUi() {
    var h = $(window).height();
    $("#main_content").css('height', h);
    $("#fileManagerPanel").css('height', h - 10);
}

var resizeTimer = null;

$(window).bind('resize', function () {
    if (resizeTimer) clearTimeout(resizeTimer);
    resizeTimer = setTimeout(resizeUi, 100);
});

function setMode(mode) {

    if (mode == 'url') {
        $('#urlImportText').show();
        $('#fileImportForm').hide();
        $('#url-btn').attr('class', 'btn btn-primary');
        $('#file-btn').attr('class', 'btn');
    } else {
        $('#urlImportText').hide();
        $('#fileImportForm').show();
        $('#url-btn').attr('class', 'btn');
        $('#file-btn').attr('class', 'btn btn-primary');
    }
}

function getMode() {

    var sel = $('.btn-group .btn-primary');
    if (sel) {
        return sel.text();
    }
    return '';
}

function getFileName() {

    var filename;
    switch (getMode()) {
        case "URL":
            filename = $('#urlImportText').val();
            break;
        case "File":
            filename = $('#fileInput').val();
            break;
        default:
            filename = '';
            break;
    }
    return filename;
}

function importFile() {

    var params = '';
    var filename = getFileName();
    if (filename == '') {
        alert("Please specify a file to import.");
        return;
    }
    if (filename.substr(filename.length - 4) == '.zip') {
        if ($('#importExtract').prop('checked')) {
            params += '&extract=true';
            if ($('#importReplace').prop('checked')) {
                params += '&clean=true';
            }
        }
    }
    switch (getMode()) {
        case 'URL':
            params += '&url=' + escape(filename);
            $.ajax({
                headers: {
                    "X-DreamFactory-API-Key": apiKey,
                    "X-DreamFactory-Session-Token": sessionToken
                },
                dataType: 'json',
                type: 'POST',
                url: CurrentServer + "/api/v2" + currentPath + "?" + params,
                data: '',
                cache: false,
                processData: false,
                success: function (response) {
                    reloadFolder();
                    $('#fileModal').modal('toggle');
                },
                error: function (response) {
                    alertErr(response);
                }
            });
            break;
        case 'File':
            $("#fileImportForm").attr("action", "/api/v2" + currentPath + "?api_key=" + apiKey + "&session_token=" + sessionToken + params);
            $("#fileImportForm").submit();
            break;
    }
}

function checkResults(iframe) {

    var str = $(iframe).contents().text();
    if (str && str.length > 0) {
        if (isErrorString(str)) {
            var response = {};
            response.responseText = str;
            alertErr(response);
        } else {
            reloadFolder();
            $('#fileModal').modal('toggle');
        }
    }
}
