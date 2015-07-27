/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'linecons\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-phone' : '&#xe000;',
			'icon-news' : '&#xe001;',
			'icon-photo' : '&#xe002;',
			'icon-shop' : '&#xe003;',
			'icon-wallet' : '&#xe004;',
			'icon-t-shirt' : '&#xe005;',
			'icon-heart' : '&#xe006;',
			'icon-cloud' : '&#xe007;',
			'icon-display' : '&#xe008;',
			'icon-diamond' : '&#xe009;',
			'icon-banknote' : '&#xe00a;',
			'icon-data' : '&#xe00b;',
			'icon-music' : '&#xe00c;',
			'icon-location' : '&#xe00d;',
			'icon-star' : '&#xe00e;',
			'icon-tv' : '&#xe00f;',
			'icon-eye' : '&#xe010;',
			'icon-megaphone' : '&#xe011;',
			'icon-study' : '&#xe012;',
			'icon-bubble' : '&#xe013;',
			'icon-sound' : '&#xe014;',
			'icon-video' : '&#xe015;',
			'icon-stack' : '&#xe016;',
			'icon-lab' : '&#xe017;',
			'icon-food' : '&#xe018;',
			'icon-cup' : '&#xe019;',
			'icon-trash' : '&#xe01a;',
			'icon-user' : '&#xe01b;',
			'icon-key' : '&#xe01c;',
			'icon-fire' : '&#xe01d;',
			'icon-clip' : '&#xe01e;',
			'icon-mail' : '&#xe01f;',
			'icon-search' : '&#xe020;',
			'icon-settings' : '&#xe021;',
			'icon-like' : '&#xe022;',
			'icon-calendar' : '&#xe023;',
			'icon-camera' : '&#xe024;',
			'icon-tag' : '&#xe025;',
			'icon-note' : '&#xe026;',
			'icon-clock' : '&#xe027;',
			'icon-lock' : '&#xe028;',
			'icon-vynil' : '&#xe029;',
			'icon-truck' : '&#xe02a;',
			'icon-paperplane' : '&#xe02b;',
			'icon-bulb' : '&#xe02c;',
			'icon-pen' : '&#xe02d;',
			'icon-params' : '&#xe02e;',
			'icon-world' : '&#xe02f;',
			'icon-arrow-left' : '&#xe032;',
			'icon-untitled' : '&#xe033;',
			'icon-arrow-left-2' : '&#xe034;',
			'icon-arrow-right' : '&#xe035;',
			'icon-arrow-left-3' : '&#xe036;',
			'icon-arrow-right-2' : '&#xe037;',
			'icon-arrow-left-4' : '&#xe038;',
			'icon-arrow-right-3' : '&#xe039;',
			'icon-female' : '&#xf182;',
			'icon-male' : '&#xf183;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, html, c, el;
	for (i = 0; ; i += 1) {
		el = els[i];
		if(!el) {
			break;
		}
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};