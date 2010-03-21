class CitiesController < ApplicationController
  
  before_filter :ensure_current_city_url, :only => :show
  
  def index
    # FIXME Why the fuck is default_scope not working??
    @cities = City.all :order => 'name asc'
    @map = initialize_google_map("map", nil, :load_icons => "icon_home", :capital => true)
  end

  def show
    @distance = params[:distance] || 15
    
    @city = City.find params[:id]
    @spots = @city.spots(:within => @distance)
    
    respond_to do |format|
      format.html do
        @map = initialize_google_map("map", nil, :load_icons => "icon_lost")

        markers = create_spots_markers(@spots)
        clusterer = Clusterer.new(markers, :max_visible_markers => 20)
        @map.overlay_init clusterer

        @center = GLatLng.new(bounding_box_center(markers))
        @map.center_zoom_init(@center, DEFAULT_ZOOM + 3)
      end
      format.xml  { render :xml => @spots }
    end
  end
  
  
  
  private
  
    def ensure_current_city_url
      # FIXME This is unnecessary if we could call this method after inherited_resources does the magic :P
      @city = City.find params[:id]
      redirect_to @city, :status => :moved_permanently unless @city.friendly_id_status.best?
    end
  
  
end
