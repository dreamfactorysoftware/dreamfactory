/*!
 * jquery.multientry.js v1.1.0
 * A plug-in to provide an entry widget for Yii/Bootstrap forms
 * Requires jQuery Validate
 * 
 * Copyright 2012-2014 Jerry Ablan <jerryablan@gmail.com>
 * Licensed under MIT
 */
;
(
	function($, window, document, undefined) {

		//**************************************************************************
		//* Plugin
		//**************************************************************************

		/**
		 * Begin the plug-in
		 * @param options
		 */
		$.fn.multientry = function(options) {

			//**************************************************************************
			//* Initialize
			//**************************************************************************

			options = $.extend({}, $.fn.multientry.options, options);
			options.replacementPattern = new RegExp(options.replacementTag, 'gi');

			//**************************************************************************
			//* Main
			//**************************************************************************

			return this.each(
				function() {
					/**
					 * Mini-me
					 * @type {*}
					 * @private
					 */
					var _model = $(this).attr('data-model');
					var _attribute = $(this).attr('data-attribute');
					var _simpleName = _model + '[' + _attribute + ']';
					var _simpleId = _model + '_' + _attribute;

					if (!options.model) {
						options.model = _model;
					}
					if (!options.attribute) {
						options.attribute = _attribute;
					}
					if (!options.name) {
						options.name = _simpleName;
					}
					if (!options.id) {
						options.id = _simpleId;
					}
					if (options.hidden) {
						$(this).addClass('hide');
					}

					var $_me = $(this);
					$_me.options = options;

					//	Create div
					var _divId = 'df-multientry-' + options.attribute;
					var _pif = 'PIF_' + _simpleId;

					//	control-group
					$('<div class="' + options.divClass + '" id="' + _pif + '" style="margin-bottom: 4px;"></div>').appendTo($_me);
					var $_pif = $('div#' + _pif);

					$('<input type="hidden" name="' + _simpleName + '" id="' + _simpleId + '" />').appendTo($_pif);

					if (options.label) {
						$('<label class="control-label">' + options.label + '</label>').appendTo($_pif);
					}

					//	List element (controls)
					$(
						'<div class="' +
						options.innerDivClass +
						'"><div class="span5" style="margin-left: 0;"><div style="margin-bottom: 0;" class="well"><ul class="nav nav-list ' +
						options.ulClass +
						'" id="' +
						options.attribute +
						'" style="min-height:' +
						options.minimumHeight +
						';"></ul></div></div></div>'
					).appendTo($_pif);

					//	Input element (control-group)
					$(
						'<div class="' +
						options.divClass +
						'"><div class="' +
						options.innerDivClass +
						'"><div class="input-append"><input data-parent="ul#' +
						options.attribute +
						'" id="df-multientry-add-item-' +
						options.attribute +
						'" class="span5 ' +
						options.inputClass +
						'" type="text" placeholder="' +
						options.placeholder +
						'" style = "margin-right:4px"><button class="' +
						options.buttonClass +
						'">Add</button></div><hr class="df-multientry-divider" style="margin:18px 0 0;" /></div></div>'
					).appendTo($_me);

					$('<style>div#' + $(this).attr('id') + ' label.error { display: block; margin-top: 4px; padding-left:	0; }</style>').appendTo($_me);

					//	Finally, add data...
					$.each(
						options.items, function(index, item) {
							//				alert(index+':'+item);
							$('ul#' + options.attribute).append(options.itemTemplate.replace(options.replacementPattern, item));
						}
					);

					//**************************************************************************
					//* Local event handler
					//**************************************************************************

					//	Fix up items
					$(
						'form' +
						(
							options.formId ? '#' + options.formId : ''
						)
					).submit(
						function() {
							var _items = '';

							$('ul#' + options.attribute + ' li').each(
								function(index, item) {
									_items += $.trim($(item).attr('id')) + ';';
								}
							);

							$('input#' + options.id).val(_items);
							return true;
						}
					);

					/**
					 * Add new item button handler
					 */
					$('button.add-new-item').on(
						'click', function(e) {
							var $_item = $('input#df-multientry-add-item-' + options.attribute);
							var _itemValue = $.trim($_item.val());

							//	Ignore errors
							if (!_itemValue.length || $(this).prev('input.ps-validate-error').length) {
								return false;
							}

							$($_item.attr('data-parent')).append(options.itemTemplate.replace(options.replacementPattern, _itemValue));
							$_item.val('');
							return false;
						}
					);

					/**
					 * Show the trash can icon on hover
					 */
					$('ul.' + options.ulClass).on(
						'mouseenter mouseleave', 'li', function(e) {
							if ('mouseenter' == e.type) {
								$('a i', $(this)).show();
							} else {
								$('a i', $(this)).hide();
							}
						}
					).on(
						'click', 'li a i.df-multientry-item', function(e) {
							if (confirm('Remove this item?')) {
								$(this).closest('li').remove();
								if (options.afterDelete) {
									options.afterDelete(this);
								}
							}
						}
					).on(
						'click', 'li a', function() {
							return false;
						}
					);

					if ($.validator) {
						$.validator.addMethod(
							'vm_df_item_validator', function(value, element) {
								var _re = new RegExp(options.validPattern, 'g');
								return this.optional(element) || _re.test(value);
							}, 'Variables may only contain letters, numbers, and . - or _'
						);

						$.validator.addClassRules(
							'df-item', {
								vm_df_item_validator: true
							}
						);
					}
				}
			);
		};

		//**************************************************************************
		//* Default Options
		//**************************************************************************

		$.fn.multientry.options = {

			formId:             null,
			hidden:             false,
			model:              null,
			attribute:          null,
			items:              [],
			validateOptions:    {},
			placeholder:        'Enter an item to add',
			label:              'Item(s)',
			labelClass:         'control-label',
			divClass:           'control-group',
			inputClass:         'df-item',
			innerDivClass:      'controls',
			ulClass:            'item-list',
			minimumHeight:      '120px',
			duplicateCheck:     null,
			buttonClass:        'btn add-new-item',
			replacementTag:     '%%item%%',
			replacementPattern: '/%%item%%/gi',
			validPattern:       '^([A-Za-z0-9\_\.\-])+$',
			name:               null, //	Or set data-name
			id:                 null, //	Or set data-id
			itemTemplate:       '<li id="%%item%%"><a href="#">%%item%%<i title="Click the trash can to delete this item" class="icon-trash pull-right df-multientry-item" style="display:none;"></i></a></li>',
			afterDelete:        function(el) {
				return true;
			},
			afterInsert:        function(el) {
				return true;
			}
		};

	}
)(jQuery, window, document);
