module MapsHelper

  def initialize_google_map(map_name, spot = nil, extra_options = {})
    raise ArgumentError, "Name of Google map can not be empty" if map_name.blank?
    
    options = {
      :icon => 'icon_spot',
      :drag => false,
      :drag_title => "Kje se nahaja WiFi točka?",
      :load_icons => %w(icon_spot icon_home),
      :capital => false,
      :zoom => ApplicationController::DEFAULT_ZOOM
    }.merge(extra_options)
    
    map = GMap.new(map_name)
    map.control_init(:small_zoom => true, :map_type => true)
    
    # Only load icons needed by map
    if options[:load_icons].include?('icon_spot')
      map.icon_global_init(GIcon.new(:image => "http://maps.google.com/mapfiles/ms/micons/red.png", :icon_size => GSize.new(26,26), :icon_anchor => GPoint.new(13,26), :info_window_anchor => GPoint.new(9,2)), "icon_spot")
    end
    
    if options[:load_icons].include?('icon_green')
      map.icon_global_init(GIcon.new(:image => "http://maps.google.com/mapfiles/ms/micons/green.png", :icon_size => GSize.new(26,26), :icon_anchor => GPoint.new(13,26), :info_window_anchor => GPoint.new(9,2)), "icon_green")
    end

    # Add draggable marker
    if spot
      if options[:drag]
        mymarker = GMarker.new(spot.latlng, :icon => Variable.new(options[:icon]), :title => options[:drag_title], :draggable => true)
        map.overlay_global_init(mymarker, "mymarker")
        map.event_init(mymarker, "dragend", "function() {
          pos = mymarker.getLatLng();
          $('lat').value = pos.lat();
          $('lng').value = pos.lng();
          }")
        map.event_init(map, "zoomend", "function() {
          $('zoom').value = map.getZoom();
        }")
      else
        mymarker = GMarker.new(spot.latlng, :icon => Variable.new(options[:icon]), :title => options[:title])
      end
      
      # Create given spot
      map.overlay_init(mymarker)
    end

    # Add markers for capital cities
    if options[:capital]
      map.icon_global_init(GIcon.new(:image => "http://maps.google.com/mapfiles/ms/micons/yellow.png", :icon_size => GSize.new(26,26), :icon_anchor => GPoint.new(13,26), :info_window_anchor => GPoint.new(14,5)), "icon_capital")    
      City.all.each do |city|
        map.overlay_init(GMarker.new(city.latlng, :icon => Variable.new("icon_capital"), :title => city.name, :info_window => "<a href='/cities/#{city.id}'>Prikaži WiFi točke v bližini</a>" ))
      end
    end
    
    
    # Center given spot
    if spot
      center = GLatLng.new(spot.latlng)
    else
      center = GLatLng.new([ApplicationController::DEFAULT_LAT,ApplicationController::DEFAULT_LNG])
    end
    map.center_zoom_init(center, options[:zoom])
    
    return map
  end


  def create_spots_markers(spots=nil)
    raise ArgumentError, "Spots array is empty" unless spots
    
    icon_spot = Variable.new("icon_spot")
    spots_markers = []
    
    spots.each do |result|
      marker = GMarker.new(result.latlng, :icon => icon_spot, :info_window => info_window_from_result(result), :title => result.title)
      spots_markers << marker
    end
    
    return spots_markers
  end
  
  def bounding_box_corners(markers)
    maxlat, maxlng, minlat, minlng = -Float::MAX, -Float::MAX, Float::MAX, Float::MAX
    markers.each do |marker|
      coord = marker.point
      maxlat = coord.lat if coord.lat > maxlat
      minlat = coord.lat if coord.lat < minlat
      maxlng = coord.lng if coord.lng > maxlng
      minlng = coord.lng if coord.lng < minlng
    end

    return [GLatLng.new([minlat, minlng]),GLatLng.new([maxlat, maxlng])]
  end
  
  def bounding_box_center(markers)
    maxlat, maxlng, minlat, minlng = -Float::MAX, -Float::MAX, Float::MAX, Float::MAX
    markers.each do |marker|
      coord = marker.point
      maxlat = coord.lat if coord.lat > maxlat
      minlat = coord.lat if coord.lat < minlat
      maxlng = coord.lng if coord.lng > maxlng
      minlng = coord.lng if coord.lng < minlng
    end
    return [(maxlat + minlat)/2, (maxlng + minlng)/2]
  end
  	
  def info_window_from_result(result)
    info = []
    info << "<h3>#{result.title}</h3>"
    if result.open?
      info << "<p><em>Odprto WiFi omrežje</em><br>"
    else
      info << "<p><em>Zaprto WiFi omrežje</em><br>"
    end
    info << "SSID: #{result.ssid}<br>" unless result.ssid.blank?
    info << "Geslo: #{result.key}<br>" unless result.key.blank?
    info << "</p>"
    info << "<p><a href=\"/spots/#{result.id}\" title=\"Poglej podatke\" style=\"font-size: 12px;\">Podrobnosti</a></p>"
    info.to_s
  end
  
end