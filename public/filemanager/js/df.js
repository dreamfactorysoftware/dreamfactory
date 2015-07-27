/**
 * DreamFactory API
 *
 * @author jb
 * @version 1.0
 *
 */

/**
 *
 * Common utilities for simplifing access to Dream Factory Data Sources
 * and Services
 *
 */
var CommonUtilities = {
    /**
     * Simplified access to the Query string on the current page's URL
     * @param key
     * @returns {Boolean}
     */
    getQueryParameter: function(key) {
        key = key.replace(/[*+?^$.\[\]{}()|\\\/]/g, "\\$&");
        var match = location.search.match(new RegExp("[?&]"+key+"=([^&]+)(&|$)"));
        return match && decodeURIComponent(match[1].replace(/\+/g, " "));
    },
    /**
     * Takes either a flattened JSON array or an array of objects with a *.getJSON()
     * method to dump the data into a request.
     *
     * @param obj
     * @returns
     */
    jsonRecords: function(obj) {
        var json = null;
        if(obj instanceof String) {
            return obj;
        } else if(obj instanceof Array) {
            var rec = [];
            for(var i in obj) {
                rec[rec.length] = {fields: obj[i].getJSON ? obj[i].getJSON() : obj[i]};
            }
            return JSON.stringify({records:{record:rec}});
        } else {
            json = {records:{record: [{fields:obj}]}};
        }
        return JSON.stringify(json);
    },
    /**
     * TODO: Still working to simplify this process for deleting records
     *
     * @param array
     * @returns
     */
    jsonDeletes: function(array) {
        var json = null;
        if(array instanceof Array) {
            throw "NOT IMPLEMENTED!"; // future use is make string array from objects
        } else if(array instanceof String) {
            json = {Ids:array};
        } else {
            json = {Ids:array.toString()};
        }
        return JSON.stringify(json);
    },
    /**
     * This method takes the response from the server and flattens it into
     * first tier objects.
     * @param json
     * @returns {Array}
     */
    flattenResponse: function(json) {
        var objects = [];
        for(var i in json.record) {
            objects[objects.length] = json.record[i].fields;
        }
        return objects;
    }
};

/**
 * Standard error detection for responses from DreamFactory
 *
 * @param xml
 * @returns {String}
 */
function checkFailure(json) {
    if(!json) return 'null result set';
    if(json.fault) {
        return json.fault.faultCode+" = "+json.fault.faultString;
    } else if(json.record) {
        var errors = [];
        for(var i in json.record) {
            if(json.record[i].fault) {
                errors[errors.length] = json.record[i].fault.faultCode+" = "+json.record[i].fault.faultString;
            }
        }
        if(errors.length > 0) return errors;
    }
}

/**
 * Form Actions (why the extra typing? For uniformity)
 */
var DFRequestType = {
    POST:'POST',
    GET:'GET'
};

/**
 * CREATE, UPDATE, DELETE & RETRIEVE (complex GETs)
 */
var DFRequestActions = {
    CREATE: null,
    UPDATE:'MERGE',
    DELETE:'DELETE',
    RETRIEVE:'GET'
};

/**
 *
 * @returns {String}
 */
function getCurrentServer() {
    var loc = window.location;
    var tmp = loc.protocol + '//' + loc.hostname;
    if(loc.port) tmp += ':'+loc.port;
    return tmp;
}

/**
 * The request object to handle communication with server
 *
 * @param opts
 * @returns {DFRequest}
 */
function DFRequest(opts) {
    // setup object...
    this.request = opts;
    this.buildUrl = function(request) {
        var str = '/REST/';
        str += request.service;
        if(request.resource) str += request.resource;
        if(request.params) {
            str += '?';
            for(var i in request.params) {
                str += escape(i);
                str += '=';
                if(request.params[i] instanceof Array) {
                    var tmp = '';
                    for(var j in request.params[i]) {
                        if(j > 0) {
                            tmp += ',';
                        }
                        tmp += request.params[i][j];
                    }
                    str += escape(tmp);
                } else {
                    str += escape(request.params[i]);
                }
                str += '&';
            }
        }
        return str;
    };

    /**
     * Template for default values, do not alter!
     */
    this.default_req = {
        async: true,
        type: DFRequestActions.RETRIEVE,
        dataType: 'json',
        cache: false,
        processData: this.request.processData ? this.request.processData : false,
        beforeSend: function(xhr) {
            xhr.setRequestHeader("X-Application-Name",(this.app ? this.app : 'launchpad'));
            if(this.action) {
                xhr.setRequestHeader("X-HTTP-Method", this.action);
            }
            if(this.file) {
                xhr.setRequestHeader("X-File-Name",this.file);
                xhr.setRequestHeader("Content-Type",this.data.type);
            }
            if(this.folder) {
                xhr.setRequestHeader("X-Folder-Name",this.folder);
            }
        },
        success: function(data){
            if(console && console.log) {
                console.log('Unhandled success callback: '+data);
            }
        },
        error: function(jqXHR, textStatus, errorThrown, request) {
            var errStr = "Error requesting resource:\n";
            if(jqXHR.status) errStr += jqXHR.status+": ";
            if(jqXHR.statusText)  errStr += "["+jqXHR.statusText+"] ";
            if(jqXHR.responseText)  errStr += "\n"+jqXHR.responseText;
            alert(errStr);
        }
    };
    /**
     * This method is intended to be used internally. Never access this directly.
     */
    this.prepareRequest = function(params,path,service,success) {
        /**
         * Create a copy of our template because fast user interaction
         * and the asynchronous nature of these calls can cause race
         * conditions on this data.
         */
        var this_request = $.extend({}, this.default_req, this.request);
        if(params) this_request.params = params;
        if(path) this_request.resource = path;
        if(service) this_request.service = service;
        this_request.url = this.buildUrl(this_request);
        if(this_request.url) { // merge our defined url with the server
            if(this_request.url.indexOf('http') != 0) {
                this_request.url = this.currentServer()+this_request.url;
            }
        }

        if(this_request.success) { // wrap call with our own management
            var custom_success = null;
            if(success) {
                custom_success = success;
            } else {
                custom_success = this_request.success; // make static reference
            }
            this_request.success = function(data) {
                if(custom_success) custom_success(data,this_request);
            };
        }

        if(this_request.error) { // wrap call with our own management
            var custom_error = this_request.error; // make static reference
            this_request.error = function(jqXHR, textStatus, errorThrown) {
                if(custom_error) custom_error(jqXHR, textStatus, errorThrown, this_request);
            };
        }

        return this_request;
    };
    /**
     * Raw post of data
     *
     * data = String of data to be posted to server
     * params = Data as name value pairs to be represented in the query string
     * path, overide the current path in a "thread safe" way for this one call
     * def = the definition used to make this call.
     *
     * TODO: the instance path for this call need to be defined better...
     *
     */
    this.post = function(data,params,path,def) {
        if(!def) def = this.prepareRequest(params,path);
        def.type = DFRequestType.POST;
        if(data) def.data = data;
        jQuery.ajax(def);
    };

    /** BELOW THIS LINE ARE RECORD REQUESTS */

    /**
     * Creates a single or mulitple records
     */
    this.create = function(records,params,path,def) {
        if(!def) def = this.prepareRequest(params,path);
        def.action = DFRequestActions.CREATE;
        this.post(CommonUtilities.jsonRecords(records), null, null, def);
    };
    /**
     * Updates a single or multiple records
     */
    this.update = function(records,params,path,def) {
        if(!def) def = this.prepareRequest(params,path);
        def.action = DFRequestActions.UPDATE;
        this.post(CommonUtilities.jsonRecords(records), null, null, def);
    };
    /**
     * Deletes a single or multiple records by ID only
     */
    this.deletes = function(records,params,path,def) {
        if(!def) def = this.prepareRequest(params,path);
        def.action = DFRequestActions.DELETE;
        this.post(CommonUtilities.jsonDeletes(records), null, null, def);
    };
    /**
     * Retrieves the records according to the object setup and parameters specified here
     */
    this.retrieve = function(params,path,def) {
        if(!def) def = this.prepareRequest(params,path);
        if(path) def.resource = path;
        def.type = DFRequestType.GET;
        def.action = DFRequestActions.RETRIEVE;
        jQuery.ajax(def);
    };

    /**
     * Utilities for simplification of certain processes
     *
     */

    this.currentServer = getCurrentServer;

}
