class @WifiMap
  constructor: () ->
    @spots = []
  
  placeSpot: (spot) ->
    console.log spot
    
    # create a latlng point
    @latlng = new google.maps.LatLng(spot.lat, spot.lng)
    console.log @latlng
    
    # defaults for map
    defaults = {
      zoom: 17, # default to 17 || spot.zoom
      center: @latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    @map = new google.maps.Map(document.getElementById("map_canvas"), defaults)
    
    # create a marker for spot
    @marker = new google.maps.Marker({
      position: @latlng, 
      map: @map, 
      title: spot.title
    })
    
    # create info window for spot
    @infowindow = new google.maps.InfoWindow(
      content: "<div><h2>#{spot.title}</h2><p>Lorem ipsum jebemti</p></div>"
      maxWidth: 300
    )
    google.maps.event.addListener @marker, 'click', -> @infowindow.open(@map, marker)
    
    @spots.push spot
    
  makeEditable: ->
    @marker.setDraggable(true)
    
    google.maps.event.addListener(@marker, 'dragend', (p) ->
      $('#lat').val(p.latLng.lat())
      $('#lng').val(p.latLng.lng())
    )
    
    google.maps.event.addListener(@map, 'zoom_changed', ->
      $('#zoom').val(this.getZoom())
    )