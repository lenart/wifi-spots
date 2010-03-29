class CategoriesController < InheritedResources::Base
  
  before_filter :authorize, :except => [:index, :show]
  
  def show
    show! do 
      @spots = @category.spots.paginate :per_page => 400, :page => params[:page]

      @map = initialize_google_map("map", nil, :load_icons => "icon_spot")

      markers = create_spots_markers(@spots)
      clusterer = Clusterer.new(markers, :max_visible_markers => 3)
      @map.overlay_init clusterer

      @center = GLatLng.new(bounding_box_corners(markers))
      @map.center_zoom_init(@center, DEFAULT_ZOOM)
    end
  end
  
  private ########################################
  
    def authorize
      unless current_user && current_user.admin?
        store_location
        flash[:notice] = "Nimate pravic za ogled te strani!"
        redirect_to root_path
        return false
      end
    end
    
end
