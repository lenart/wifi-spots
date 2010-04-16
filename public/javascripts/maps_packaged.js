function addInfoWindowToMarker(marker,info,options){GEvent.addListener(marker,"click",function(){marker.openInfoWindowHtml(info,options);});return marker;}
function addInfoWindowTabsToMarker(marker,info,options){GEvent.addListener(marker,"click",function(){marker.openInfoWindowTabsHtml(info,options);});return marker;}
function addPropertiesToLayer(layer,getTile,copyright,opacity,isPng){layer.getTileUrl=getTile;layer.getCopyright=copyright;layer.getOpacity=opacity;layer.isPng=isPng;return layer;}
function addOptionsToIcon(icon,options){for(var k in options){icon[k]=options[k];}
return icon;}
function addCodeToFunction(func,code){if(func==undefined)
return code;else{return function(){func();code();}}}
function addGeocodingToMarker(marker,address){marker.orig_initialize=marker.initialize;orig_redraw=marker.redraw;marker.redraw=function(force){};marker.initialize=function(map){new GClientGeocoder().getLatLng(address,function(latlng){if(latlng){marker.redraw=orig_redraw;marker.orig_initialize(map);marker.setPoint(latlng);}});};return marker;}
GMap2.prototype.centerAndZoomOnMarkers=function(markers){var bounds=new GLatLngBounds(markers[0].getPoint(),markers[0].getPoint());for(var i=1,len=markers.length;i<len;i++){bounds.extend(markers[i].getPoint());}
this.centerAndZoomOnBounds(bounds);}
GMap2.prototype.centerAndZoomOnPoints=function(points){var bounds=new GLatLngBounds(points[0],points[0]);for(var i=1,len=points.length;i<len;i++){bounds.extend(points[i]);}
this.centerAndZoomOnBounds(bounds);}
GMap2.prototype.centerAndZoomOnBounds=function(bounds){var center=bounds.getCenter();this.setCenter(center,this.getBoundsZoomLevel(bounds));}
function setWindowDims(elem){if(window.innerWidth){elem.style.height=(window.innerHeight)+'px;';elem.style.width=(window.innerWidth)+'px;';}else if(document.body.clientWidth){elem.style.width=(document.body.clientWidth)+'px';elem.style.height=(document.body.clientHeight)+'px';}}
ManagedMarker=function(markers,minZoom,maxZoom){this.markers=markers;this.minZoom=minZoom;this.maxZoom=maxZoom;}
function addMarkersToManager(manager,managedMarkers){for(var i=0,length=managedMarkers.length;i<length;i++){mm=managedMarkers[i];manager.addMarkers(mm.markers,mm.minZoom,mm.maxZoom);}
manager.refresh();return manager;}
var INVISIBLE=new GLatLng(0,0);if(self.Event&&Event.observe){Event.observe(window,'unload',GUnload);}else{window.onunload=GUnload;}
var WGS84_SEMI_MAJOR_AXIS=6378137.0;var WGS84_ECCENTRICITY=0.0818191913108718138;var DEG2RAD=0.0174532922519943;var PI=3.14159267;function dd2MercMetersLng(p_lng){return WGS84_SEMI_MAJOR_AXIS*(p_lng*DEG2RAD);}
function dd2MercMetersLat(p_lat){var lat_rad=p_lat*DEG2RAD;return WGS84_SEMI_MAJOR_AXIS*Math.log(Math.tan((lat_rad+PI/2)/2)*Math.pow(((1-WGS84_ECCENTRICITY*Math.sin(lat_rad))/(1+WGS84_ECCENTRICITY*Math.sin(lat_rad))),(WGS84_ECCENTRICITY/2)));}
function addWMSPropertiesToLayer(tile_layer,base_url,layers,styles,format,merc_proj,use_geo){tile_layer.format=format;tile_layer.baseURL=base_url;tile_layer.styles=styles;tile_layer.layers=layers;tile_layer.mercatorEpsg=merc_proj;tile_layer.useGeographic=use_geo;return tile_layer;}
getTileUrlForWMS=function(a,b,c){var lULP=new GPoint(a.x*256,(a.y+1)*256);var lLRP=new GPoint((a.x+1)*256,a.y*256);var lUL=G_NORMAL_MAP.getProjection().fromPixelToLatLng(lULP,b,c);var lLR=G_NORMAL_MAP.getProjection().fromPixelToLatLng(lLRP,b,c);if(this.useGeographic){var lBbox=lUL.x+","+lUL.y+","+lLR.x+","+lLR.y;var lSRS="EPSG:4326";}else{var lBbox=dd2MercMetersLng(lUL.x)+","+dd2MercMetersLat(lUL.y)+","+dd2MercMetersLng(lLR.x)+","+dd2MercMetersLat(lLR.y);var lSRS="EPSG:"+this.mercatorEpsg;}
var lURL=this.baseURL;lURL+="?REQUEST=GetMap";lURL+="&SERVICE=WMS";lURL+="&VERSION=1.1.1";lURL+="&LAYERS="+this.layers;lURL+="&STYLES="+this.styles;lURL+="&FORMAT=image/"+this.format;lURL+="&BGCOLOR=0xFFFFFF";lURL+="&TRANSPARENT=TRUE";lURL+="&SRS="+lSRS;lURL+="&BBOX="+lBbox;lURL+="&WIDTH=256";lURL+="&HEIGHT=256";lURL+="&reaspect=false";return lURL;}
function GeoRssOverlay(rssurl,icon,proxyurl,options){this.rssurl=rssurl;this.icon=icon;this.proxyurl=proxyurl;if(options['visible']==undefined)
this.visible=true;else
this.visible=options['visible'];this.listDiv=options['listDiv'];this.contentDiv=options['contentDiv'];this.listItemClass=options['listItemClass'];this.limitItems=options['limit'];this.request=false;this.markers=[];}
GeoRssOverlay.prototype=new GOverlay();GeoRssOverlay.prototype.initialize=function(map){this.map=map;this.load();}
GeoRssOverlay.prototype.redraw=function(force){}
GeoRssOverlay.prototype.remove=function(){for(var i=0,len=this.markers.length;i<len;i++){this.map.removeOverlay(this.markers[i]);}}
GeoRssOverlay.prototype.showHide=function(){if(this.visible){for(var i=0;i<this.markers.length;i++){this.map.removeOverlay(this.markers[i]);}
this.visible=false;}else{for(var i=0;i<this.markers.length;i++){this.map.addOverlay(this.markers[i]);}
this.visible=true;}}
GeoRssOverlay.prototype.showMarker=function(id){var marker=this.markers[id];if(marker!=undefined){GEvent.trigger(marker,"click");}}
GeoRssOverlay.prototype.copy=function(){var oCopy=new GeoRssOVerlay(this.rssurl,this.icon,this.proxyurl);oCopy.markers=[];for(var i=0,len=this.markers.length;i<len;i++){oCopy.markers.push(this.markers[i].copy());}
return oCopy;}
GeoRssOverlay.prototype.load=function(){if(this.request!=false){return;}
this.request=GXmlHttp.create();if(this.proxyurl!=undefined){this.request.open("GET",this.proxyurl+'?q='+encodeURIComponent(this.rssurl),true);}else{this.request.open("GET",this.rssurl,true);}
var m=this;this.request.onreadystatechange=function(){m.callback();}
this.request.send(null);}
GeoRssOverlay.prototype.callback=function(){if(this.request.readyState==4){if(this.request.status=="200"){var xmlDoc=this.request.responseXML;if(xmlDoc.documentElement.getElementsByTagName("item").length!=0){var items=xmlDoc.documentElement.getElementsByTagName("item");}else if(xmlDoc.documentElement.getElementsByTagName("entry").length!=0){var items=xmlDoc.documentElement.getElementsByTagName("entry");}
for(var i=0,len=this.limitItems?Math.min(this.limitItems,items.length):items.length;i<len;i++){try{var marker=this.createMarker(items[i],i);this.markers.push(marker);if(this.visible){this.map.addOverlay(marker);}}catch(e){}}}
this.request=false;}}
GeoRssOverlay.prototype.createMarker=function(item,index){var title=item.getElementsByTagName("title")[0].childNodes[0].nodeValue;if(item.getElementsByTagName("description").length!=0){var description=item.getElementsByTagName("description")[0].childNodes[0].nodeValue;var link=item.getElementsByTagName("link")[0].childNodes[0].nodeValue;}else if(item.getElementsByTagName("summary").length!=0){var description=item.getElementsByTagName("summary")[0].childNodes[0].nodeValue;var link=item.getElementsByTagName("link")[0].attributes[0].nodeValue;}
if(navigator.userAgent.toLowerCase().indexOf("msie")<0){if(item.getElementsByTagNameNS("http://www.w3.org/2003/01/geo/wgs84_pos#","lat").length!=0){var lat=item.getElementsByTagNameNS("http://www.w3.org/2003/01/geo/wgs84_pos#","lat")[0].childNodes[0].nodeValue;var lng=item.getElementsByTagNameNS("http://www.w3.org/2003/01/geo/wgs84_pos#","long")[0].childNodes[0].nodeValue;}else if(item.getElementsByTagNameNS("http://www.georss.org/georss","point").length!=0){var latlng=item.getElementsByTagNameNS("http://www.georss.org/georss","point")[0].childNodes[0].nodeValue.split(" ");var lat=latlng[0];var lng=latlng[1];}}else{if(item.getElementsByTagName("geo:lat").length!=0){var lat=item.getElementsByTagName("geo:lat")[0].childNodes[0].nodeValue;var lng=item.getElementsByTagName("geo:long")[0].childNodes[0].nodeValue;}else if(item.getElementsByTagName("georss:point").length!=0){var latlng=item.getElementsByTagName("georss:point")[0].childNodes[0].nodeValue.split(" ");var lat=latlng[0];var lng=latlng[1];}}
var point=new GLatLng(parseFloat(lat),parseFloat(lng));var marker=new GMarker(point,{'title':title});var html="<a href=\""+link+"\">"+title+"</a><p/>"+description;if(this.contentDiv==undefined){GEvent.addListener(marker,"click",function(){marker.openInfoWindowHtml(html);});}else{var contentDiv=this.contentDiv;GEvent.addListener(marker,"click",function(){document.getElementById(contentDiv).innerHTML=html;});}
if(this.listDiv!=undefined){var a=document.createElement('a');a.innerHTML=title;a.setAttribute("href","#");var georss=this;a.onclick=function(){georss.showMarker(index);return false;};var div=document.createElement('div');if(this.listItemClass!=undefined){div.setAttribute("class",this.listItemClass);}
div.appendChild(a);document.getElementById(this.listDiv).appendChild(div);}
return marker;}