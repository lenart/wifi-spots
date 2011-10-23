class @WifiMap
  constructor: () ->
    defaults = {
      center: new google.maps.LatLng(46.0620023, 14.5096064),
      zoom: 12,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    @spots = []
    @info = null
    @map = new google.maps.Map(document.getElementById("map_canvas"), defaults)
    
  placeSpots: (spots) ->
    @placeSpot spot for spot in spots
    
  placeSpot: (spot, showInfo = false) ->
    spot.latlng = new google.maps.LatLng(spot.lat, spot.lng)
    spot.marker = new google.maps.Marker({position: spot.latlng, map: @map, title: spot.title})
    
    if showInfo
      # create info window for spot
      spot.infowindow = new google.maps.InfoWindow(
        content: "<div><h3>#{spot.title}</h3><p style='margin-top: 10px;'><a href=\"#{spot.permalink}\">Podrobnosti</a></p></div>"
        maxWidth: 300
      )
      google.maps.event.addListener spot.marker, 'click', =>
        @info.close() if @info
        @info = spot.infowindow
        spot.infowindow.open(@map, spot.marker)
      
    @spots.push spot
  
  makeEditable: (spot) ->
    marker = spot.marker
    marker.setDraggable(true)

    google.maps.event.addListener(marker, 'dragend', (p) ->
      $('#lat').val(p.latLng.lat())
      $('#lng').val(p.latLng.lng())
    )
    google.maps.event.addListener(@map, 'zoom_changed', ->
      $('#zoom').val(this.getZoom())
    )