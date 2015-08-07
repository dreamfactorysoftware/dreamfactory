/*!
 * jQuery QueryString v1.1.0 (Release version)
 *
 * http://www.darlesson.com/
 *
 * Copyright 2013, Darlesson Oliveira
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * @requires jQuery v1.3.2 or above
 *
 * Reporting bugs, comments or suggestions: http://darlesson.com/contact/
 * Documentation and other jQuery plug-ins: http://darlesson.com/jquery/
 * Donations are welcome: http://darlesson.com/donate/
 */
 
(function (e, t) { "use strict"; var n = function () { var t = { href: window.location.href, multipleAsArray: false, isCaseSensitive: false }; var n = function (r, i) { if (!this instanceof n) return new n(r, i); this._options = e.extend({}, t, i || {}); this.size = 0; this.parameters = {}; this._init(r) }; n.prototype._init = function (e) { var t = this._options, n = t.multipleAsArray, r = t.href.toString(), i = r.lastIndexOf("?") > -1 ? r.substring(r.lastIndexOf("?") + 1, r.length) : null, s = [], o = i.lastIndexOf("#"); if (o) i = i.substring(0, o); if (i) s = i.split("&"); if (s.length) { var u = -1, a = "", f = -1, l = false, c, h; while (u++ && u < s.length || u < s.length) { a = s[u]; f = a.indexOf("="); if (f > 0) { c = a.substring(0, f); h = a.substring(f + 1); l = this.parameters.hasOwnProperty(c); if (n && l) { if (typeof this.parameters[c] === "string") this.parameters[c] = [this.parameters[c]]; this.parameters[c].push(h) } else if (!l) this.parameters[c] = h; this.size++ } } } }; return n }(); e.QueryString = function (t, r) { return function (t, r) { var i = { isCaseSensitive: false, index: null }, r = e.extend({}, i, r || {}); var s = typeof r.index == "number"; if (s) r.multipleAsArray = true; var o = new n(t, r); var u = r.isCaseSensitive, t = typeof t === "string" ? u ? t : t.toLowerCase() : null; if (typeof t === "string") { if (s && o.parameters[t] && o.parameters[t].constructor == Array) return o.parameters[t][r.index]; return o.parameters[t] } else { if (o.parameters) { var a; for (a in o.parameters) this[a] = o.parameters[a] } this["size"] = o.size; return this } }.apply({}, [t, r]) }; e.HashString = function (t, n) { var r = { href: window.location.href }, i = e.extend({}, r, n); var s = i.href, o; if (typeof t == "string" && t.indexOf("#") == 0) { if (t.lastIndexOf(t)) { o = true } } return i.href() } })(jQuery);