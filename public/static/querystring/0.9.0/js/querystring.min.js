/*!
 * jQuery QueryString v0.9.0 (Beta version)
 *
 * http://www.darlesson.com/
 *
 * Copyright 2010, Darlesson Oliveira
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
 
(function($){$.QueryString=function(queryString,options){var defaults={href:window.location.href,index:null,isCaseSensitive:true},settings=$.extend({},defaults,options);var isCaseSensitive=settings.isCaseSensitive,queryString=(queryString==null)?null:(isCaseSensitive)?queryString.toString():queryString.toString().toLowerCase(),href=settings.href.toString(),href=(href.lastIndexOf("?")>-1)?href.substring(href.lastIndexOf("?")+1,href.length):null;this.size=0;if(href&&!queryString){var arr=href.split("&"),arrValue="",thisObject="";this.size=arr.length;for(var x=0;x<arr.length;x++){var query=(isCaseSensitive)?arr[x].split("=")[0]:arr[x].split("=")[0].toLowerCase(),value=arr[x].split("=")[1],insertComma=(arrValue=="")?"[{":", ";arrValue+=(insertComma+""+query+" : '"+value+"'");thisObject+=("this."+query+" = '"+value+"';");}
arrValue=eval(arrValue+"}]")[0];eval(thisObject);return this;}else if(href&&queryString&&href.indexOf(queryString+"=")>-1){var arr=href.split("&"),firstItemValue=null,count=0,arrValue=new Array();for(var x=0;x<arr.length;x++){var query=(isCaseSensitive)?arr[x].split("=")[0]:arr[x].split("=")[0].toLowerCase(),value=arr[x].split("=")[1];if(isNaN(settings.index)||settings.index>arr.length){return null;}else if(query==queryString&&settings.index===x){return value;}else if(query==queryString){if(!firstItemValue){firstItemValue=value;};arrValue[count]=value;count+=1;};};if(arrValue.length>1){return arrValue;}else{return firstItemValue;};}else if(href&&queryString&&href.indexOf(queryString+"=")==-1){return null;};return null;};})(jQuery);