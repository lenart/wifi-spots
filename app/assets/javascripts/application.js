// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// require jquery
// require jquery_ujs

//= require prototype
//= require effects
//= require controls
//= require dragdrop

//= require ym4r-gm
//= require wms-gs
//= require clusterer
//= require markerGroup
//= require geoRssOverlay

//= require test

// require_tree .

var InfoWindow = Class.create({
  template: new Template("<div>#{title}</div>"),
  info: null, map: null,
  
  show: function(spot) {
    var content = this.template.evaluate(spot)
    this.info.setContent(content)
    this.info.open(this.map,spot.marker)
  },
  
  close: function() {
    this.info.close()
  },
  
  initialize: function(map) {
    this.info = new google.maps.InfoWindow()
    this.map = map
    var dis = this
    // close info window when click is anywhere on the map
    google.maps.event.addListener(this.map, 'click', function() {
      app.infoWindow.close();
    });
  }
})

var Spot = Class.create({
  id:null, title:null, lat:null, lng:null, zoom:null,
  latlng:null, marker:null, map:null, draggable:null,
  listenStart:null, listenEnd:null,
  
  createGmaps: function() {
    this.latlng = new google.maps.LatLng(this.lat,this.lng)
    this.marker = new google.maps.Marker({
      position: this.latlng,
      map: this.map,
      title: this.title,
      draggable: Boolean(this.draggable)
    })
    
    // add listeners for click
    var dis = this
    google.maps.event.addListener(dis.marker, 'click', function() {
      app.infoWindow.show(dis)
    })
  },
  
  centerMap: function() {
    this.map.setCenter(this.latlng)
    this.map.setZoom(this.zoom)
  },
  
  dragEnable: function() {
    var dis = this
    this.marker.setDraggable(true)
    
    this.listenStart = google.maps.event.addListener(dis.marker, 'dragstart', function(m) {
      console.log("Start dragging")
    })
    
    this.listenEnd = google.maps.event.addListener(dis.marker, 'dragend', function(m) {
      console.log("End dragging")
      // do we need to update marker position at this point?
      dis.latlng = m.latLng
      dis.map.panTo(dis.latlng)
      dis.updateForm()
    })
  },
  
  dragDisable: function() {
    this.marker.setDraggable(false)
    google.maps.event.removeListener(this.listenStart) 
    google.maps.event.removeListener(this.listenEnd) 
  },
  
  updateForm: function() {
    if (this.id) {
      var formName = 'edit_spot_'+this.id
    } else {
      var formName = 'new_spot'
    }
    var form = $(formName)
    if (form) {
      form.lat.value = this.latlng.lat()
      form.lng.value = this.latlng.lng()
      form.zoom.value = this.map.getZoom()
    }
  },
  
  initialize: function(json,map,draggable) {
    if (json.spot) json = json.spot // when creating single node
    this.id = json.id
    this.title = json.title
    this.lat = json.lat
    this.lng = json.lng
    this.zoom = json.zoom
    this.map = map
    this.draggable = draggable;

    this.createGmaps()
  }
})


var WifiMap = Class.create({
  app: null, jsonSpots: null, spots: [],
  map: null, infoWindow:null,
  
  buildSpots: function(jsonSpots) {
    for (var i = 0; i < jsonSpots.length; i++) {
      var spot = new Spot(jsonSpots[i], this.map, false)
      this.spots.push(spot)
    }
    this.centerMarkers()
  },
  
  centerMarkers: function() {
    // Center single marker or multiple markers
    if (this.spots.length > 1) {
      var bounds = new google.maps.LatLngBounds()
      for (i=0;i<this.spots.length-1;i++) {
        bounds.extend(this.spots[i].latlng);
      }
      this.map.fitBounds(bounds)
    } else {
      this.spots[0].centerMap()
    }
  },
  
  initialize: function(jsonSpots) {
    var myOptions = { mapTypeId: google.maps.MapTypeId.ROADMAP }
    this.map = new google.maps.Map($("map_canvas"), myOptions)
    this.buildSpots(jsonSpots)
      
    this.infoWindow = new InfoWindow(this.map)
  }
  
})


var UI = {
  
  toggleNotes: function(clear) {
    if ($('notes').visible()) {
      UI.hideNotes(true);
    } else {
      UI.showNotes();
    }
  },
  
  hideNotes: function(clear) {
    $('notes').hide();
    if (clear==true) {
      $('spot_notes').value = '';
    }
    $('toggle_notes').show();
  },

  showNotes: function() {
    $('notes').show();
    $('toggle_notes').hide();
  },

	showPass: function() {
		$('pass_t').show();
		$('pass_d').show();
	},
	
	hidePass: function() {
		$('pass_t').hide();
		$('pass_d').hide();
	},
	
	passState: function() {
		var active = $("spot_open").getValue();
		var pass = $("pass");
		(active == "false") ? UI.showPass() : UI.hidePass();
	}
  
};