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
 * Our main DSP settings and cache
 * @type {{DSP_EVENT: string, debug: boolean}}
 */
Platform = {
	/**
	 * Constants
	 */
	DSP_EVENT: 'dsp.event',
	/**
	 * General Settings
	 */
	/** @type boolean */
	debug:     true
};

/** @type {{stream: {enabled: boolean, source: null, id: null, url: string, message: Function, relay_event: Function, open: Function, error: Function}, init: Function}} */
Platform.events = {
	/**     * @type {*}     */
	stream: {
		/** @type boolean */
		enabled: false,
		/** @type Window.EventSource */
		source:  null,
		/** @type string */
		id:      null,
		/** @type string */
		url:     '/rest/system/event_stream/?app_name=event_stream',

		/**
		 * Message Handler
		 * @param event
		 */
		message: function(event) {
			var _data = JSON.parse(event.data);
			if (Platform.debug) {
				console.log('MESSAGE event received: ' + _data.details.type + ' -> ' + event.data);
			}

			//	Route message if wanted
			if (Platform.DSP_EVENT == _data.details.type && $.isFunction(Platform.events.relay_event)) {
				Platform.events.relay_event(_data.details.type, _data);
			}
		},

		/**
		 * Routes messages to jQuery
		 *
		 * @param eventType
		 * @param eventData
		 */
		relay_event: function(eventType, eventData) {
			$(window).trigger(eventType, eventData);
			if (Platform.debug) {
				console.log('ROUTED event to jQuery: ' + eventType + ' -> ' + JSON.stringify(eventData));
			}
		},

		/**
		 * Open Handler
		 * @param [event]
		 */
		open: function(event) {
			if (Platform.debug) {
				console.log('OPEN event received: ' + JSON.stringify(event));
			}
		},

		/**
		 * Error Handler
		 * @param [event]
		 */
		error: function(event) {
			if (Platform.debug) {
				console.log('ERROR event received: ' + JSON.stringify(event));
			}
		}
	},

	/**
	 * Initializes the event stream
	 * @param {[Platform.events.stream]} stream Optional non-system event source
	 */
	init: function(stream) {
		var _stream = stream || Platform.events.stream;

		if (_stream.enabled && !_stream.source && 'undefined' !== typeof('EventSource')) {
			_stream.source = new EventSource(_stream.url);
			_stream.source.addEventListener('message', this.events.message);
			_stream.source.addEventListener('dsp.event', this.events.message);
			_stream.source.addEventListener('open', this.events.open);
			_stream.source.addEventListener('error', this.events.error);
			_stream.enabled = true;
		}

		return _stream.source;

	}
};
