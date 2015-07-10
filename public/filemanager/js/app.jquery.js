/**
 * app.jquery.js
 * The file contains client-side functions that are global to the entire application.
 */

/**
 * Our global options
 */
var _options = {
	alertHideDelay:      5000,
	notifyDiv:           'div#request-message',
	masterTable:         'table#master-table',
	detailsDiv:          'div#master-detail',
	detailsTable:        'table#details-table',
	detailsTitle:        'h3#details-table-title',
	detailsCallback:     function(data, status, xhr, element) {
	},
	ajaxMessageFadeTime: 6000
};

/**
 * Shows a spinner
 * @param stop
 * @private
 */
var _wait = function(stop) {
	if (stop) {
		$('span#background-activity').addClass('hide');
		$('body').css({cursor: 'default'});

		$('span.loading-message').fadeOut(_options.ajaxMessageFadeTime, function() {
			$(this).empty();
		});
	}
	else {
		$('span#background-activity').removeClass('hide');
		$('body').css({cursor: 'wait'});
	}
};

/**
 * Shows a notification
 * @param style
 * @param options
 */
var notify = function(style, options) {
	var $_element = $('form:visible');
	var _message;

	if ('Success!' == options.title) {
		_message =
			'<div id="success-message" class="alert alert-block alert-success"><button type="button" class= "close" data-dismiss="alert">×</button><h4>' +
				options.title + '</h4>' + options.text + '</div>';
	}
	else {
		_message =
			'<div id="failure-message" class="alert alert-block alert-error"><button type="button" class= "close" data-dismiss="alert">×</button><h4>' +
				options.title + '</h4>' + options.text + '</div>';
	}

	if ($_element.length) {
		$_element.before(_message);
	}
	else {
		$_element = $('h1.ui-generated-header');
		if (!$_element.length) {
			return;
		}
		$_element.after(_message);
	}
};

/**
 * @private
 * @param element
 * @param errorClass
 */
var _highlightError = function(element, errorClass) {
	$(element).closest('div.form-group').addClass('error');
	$(element).addClass(errorClass);
};

/**
 * @private
 * @param element
 * @param errorClass
 */
var _unhighlightError = function(element, errorClass) {
	$(element).closest('div.form-group').removeClass('error');
	$(element).removeClass(errorClass);
};

/**
 * Initialize any buttons and set fieldset menu classes
 */
$(function() {
	/**
	 * Clear any alerts after configured time
	 */
	if (_options.alertHideDelay) {
		window.setTimeout(function() {
			$('div.alert').not('.alert-fixed').fadeTo(500, 0).slideUp(500, function() {
				$(this).remove();
			});
		}, _options.alertHideDelay);
	}
});
