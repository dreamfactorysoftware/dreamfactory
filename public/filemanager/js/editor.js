/**
 * editor.js
 */
//document.write('<title>Editing: '+CommonUtilities.getQueryParameter('path')+'</title>');


EditorActions = {
    getFile : function(){

        $.ajax({
            url:CurrentServer + '/rest' + EditorActions.getQueryParameter('path'),
            data:'app_name=admin&method=GET',
            cache:false,
            processData: false,
            dataType: "text",
            success:function (response) {
                var filename = EditorActions.getFileName();
                var mode = null;
//                if(filename.indexOf(".json") != -1){
//                    response = JSON.stringify(response, undefined, 2); // indentation level = 2
//                    //response = JSON.stringify(response)
//                    mode = 'json';
//                }
                if(mode){
                EditorActions.loadEditor(response, mode);
                }else{
                EditorActions.loadEditor(response);
                }
            },
            error:function (response) {
                if (response.status == 401) {
                    window.opener.window.top.Actions.doSignInDialog();
                } else if(response.status == 200){
                    EditorActions.loadEditor(response.responseText);
                }else{
                    alertErr(response);
                }
            }
        });
    },
    getFileName:function () {
        var pathArray = EditorActions.getQueryParameter('path').split('/');

        return pathArray[pathArray.length - 1];
    },
    saveFile:function(){
        var fileData = Editor.getValue();
        var filename = EditorActions.getFileName();
        if(filename.indexOf(".json") != -1){
            fileData = unescape(fileData);
            fileData = fileData.replace("\n","");
        }

        $.ajax({
            url:CurrentServer + '/rest' + EditorActions.getQueryParameter('path') + '?&app_name=admin',
            data: fileData,
            type:'PUT',
            processData: false,
            cache:false,
            beforeSend: function(xhr) {
                xhr.setRequestHeader("X-File-Name",EditorActions.getFileName());
            },
            success:function (response) {
                $.pnotify({
                    title: EditorActions.getFileName(),
                    type: 'success',
                    text: 'Saved Successfully'
                });
            },
            error:function (response) {
                if (response.status == 401) {
                    window.opener.window.top.Actions.doSignInDialog();
                } else {
                    alertErr(response);
                }
            }
        });
    },
    loadEditor:function(contents, mode){
        Editor = ace.edit("editor");
        Editor.setTheme("ace/theme/twilight");
        if(mode){
            Editor.getSession().setMode("ace/mode/json");
        }else{
            Editor.getSession().setMode("ace/mode/javascript");
        }

        Editor.setValue(contents, -1);
        Editor.focus();

        $("#save").click(function(){
            EditorActions.saveFile();
        });

        $("#close").click(function(){
            window.close();
        });
    },
    getQueryParameter: function(key) {
        key = key.replace(/[*+?^$.\[\]{}()|\\\/]/g, "\\$&");
        var match = location.search.match(new RegExp("[?&]"+key+"=([^&]+)(&|$)"));
        return match && decodeURIComponent(match[1].replace(/\+/g, " "));
    }
};
$(document).ready(function(){
    EditorActions.getFile();

});