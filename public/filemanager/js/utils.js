/**
 * This file is part of the DreamFactory Services Platform(tm) (DSP)
 *
 * DreamFactory Services Platform(tm) <http://github.com/dreamfactorysoftware/dsp-core>
 * Copyright 2012-2014 DreamFactory Software, Inc. <support@dreamfactory.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * General Purpose Functions
 */

/** @type {*} */
var Config = {};
/** @type {*} */
var CurrentSession = {};
/** @type {integer} */
var CurrentUserID = null;
/** @type {string} */
var CurrentServer = window.location.protocol + '//' + window.location.host;

/**
 * @param response
 */
function alertErr(response) {
	alert(getErrorString(response));
}

/**
 * @param responseText
 * @returns {boolean}
 */
function isErrorString(responseText) {
	var result = null;

	if (responseText) {
		try {
			result = JSON.parse(responseText);
		}
		catch (e) {
		}
	}

	return !!(result && result.error);
}

function getErrorString(response) {
	var code = null;
	var value = null;
	var result = null;

	if (response) {
		value = response.status;
		if (value) {
			code = value;
		}
		value = response.responseText;
		if (value) {
			try {
				result = JSON.parse(value);
			}
			catch (e) {

			}
		} else {
			result = response.data;
		}
		if (result && result.error) {
			value = xml2text(result.error[0].message);
			if (0 == value.indexOf('Batch Error')) {
				var details = result.error[0].context;
				if (0 < details.errors.length) {
					var index = details.errors[0];
					value = xml2text(details.record[index]);
				}
			}
			if (value) {
				return value;
			}
			value = result.error[0].code;
			if (value) {
				code = value;
			}
		}
		if (null !== code) {
			return 'Server returned error code ' + code + '.';
		}
	}
	return 'Server returned an unknown error.';
}

function text2xml(value) {
	return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(
		/"/g,
		'&quot;'
	).replace(/\'/g, '&apos;');
}

function xml2text(value) {
	return value.replace(/&quot;/g, '"').replace(/&gt;/g, '>').replace(/&lt;/g, '<').replace(
		/&amp;/g,
		'&'
	).replace(/&apos;/g, '\'');
}

function getFileExtension(name) {
	var found = name.lastIndexOf('.') + 1;
	return (0 < found ? name.substr(found) : "");
}

var removeByAttr = function(arr, attr, value) {
	if (!arr) {
		return false;
	}
	var i = arr.length;
	while (i--) {
		if (arr[i] && arr[i][attr] && (2 < arguments.length && arr[i][attr] === value )) {
			arr.splice(i, 1);
		}
	}
	return arr;
};

var removeByAttrs = function(arr, attr1, value1, attr2, value2) {
	if (!arr) {
		return false;
	}
	var i = arr.length;
	while (i--) {
		if (arr[i] && arr[i][attr1] && (2 < arguments.length && arr[i][attr1] === value1 )) {
			if (arr[i][attr2] && (2 < arguments.length && arr[i][attr2] === value2)) {
				arr.splice(i, 1);
			}

		}
	}
	return arr;
};

var updateByAttr = function(arr, attr1, value1, newRecord) {
	if (!arr) {
		return false;
	}
	var i = arr.length;
	while (i--) {
		if (arr[i] && arr[i][attr1] && (2 < arguments.length && arr[i][attr1] === value1 )) {

			//arr.splice(i,1);
			arr[i] = newRecord;

		}
	}
	return arr;
};

/**
 *
 * @param arr
 * @param attr1
 * @param value1
 * @param attr2
 * @param value2
 * @returns {boolean}
 */
var checkForDuplicates = function(arr, attr1, value1, attr2, value2) {
	if (!arr) {
		return false;
	}
	var i = arr.length;
	var found = false;
	while (i--) {
		if (arr[i] && arr[i][attr1] && (2 < arguments.length && arr[i][attr1] === value1 )) {
			if (arr[i][attr2] && (2 < arguments.length && arr[i][attr2] === value2)) {
				found = true;
			}

		}
	}
	return found;
};

/**
 *
 * @param arr
 * @param attr1
 * @param value1
 * @returns {boolean}
 */
var checkForDuplicate = function(arr, attr1, value1) {
	if (!arr) {
		return false;
	}
	var i = arr.length;
	var found = false;
	while (i--) {
		if (arr[i] && arr[i][attr1] && (2 < arguments.length && arr[i][attr1] === value1 )) {

			found = true;

		}
	}
	return found;
};

/**
 * @param {string} appUrl
 * @param {string} appName
 * @returns {string}
 */
var replaceParams = function(appUrl, appName) {
	var newParams = "";
	var url = appUrl;
	if (appUrl.indexOf("?") !== -1) {
		var temp = appUrl.split("?");
		url = temp[0];
		var params = temp[1];
		params = params.split("&");
		$.each(
			params, function(index, oneParam) {
				if (oneParam) {
					if ("" === newParams) {
						newParams += "?";
					} else {
						newParams += "&";
					}
					var pieces = oneParam.split("=");
					if (1 < pieces.length) {
						var name = pieces.shift();
						var value = pieces.join("=");

						switch (value) {
							case "{session_id}":
							case "{ticket}":
							case "{first_name}":
							case "{last_name}":
							case "{display_name}":
							case "{email}":
								value = value.substring(1, value.length - 1);
								value = top.CurrentSession[value];
								break;
							case "{user_id}":
								value = top.CurrentSession.id;
								break;
							case "{app_name}":
								value = appName;
								break;
							case "{server_url}":
								value = top.CurrentServer;
								break;
						}

						newParams += name + "=" + value;
					} else {
						newParams += oneParam;
					}
				}
			}
		);
	}

	return url + newParams;
};
