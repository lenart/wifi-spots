class SpotsController < InheritedResources::Base
  
  # before_filter :require_user, :only => [:edit, :update, :destroy]
  # before_filter :authorize, :only => [:edit, :update, :destroy]
  before_filter :require_admin, :only => [:revert, :destroy]
  before_filter :ensure_friendly_url, :only => :show
  
  def index
    @spots = Spot.active.paginate :page => params[:page], :per_page => 500
    
    respond_to do |format|
      format.html do
        @map = initialize_google_map("map", nil, :load_icons => "icon_lost")

        markers = create_spots_markers(@spots)
        clusterer = Clusterer.new(markers, :max_visible_markers => 10)
        @map.overlay_init clusterer

        @center = GLatLng.new(bounding_box_center(markers))
        @map.center_zoom_init(@center, DEFAULT_ZOOM)
      end
      format.xml { render :xml => @spots }      
    end
  end
  
  def show
    show! {
      @map = initialize_google_map('map', @spot, :icon => "icon_lost", :title => @spot.title, :zoom => @spot.zoom)
    }
  end
    
  def new
    new! do
      @spot.lat, @spot.lng = DEFAULT_LAT, DEFAULT_LNG
      @spot.zoom = DEFAULT_ZOOM
      
      @map = initialize_google_map('map', @spot, :drag => true, :drag_title => "Kje se nahaja WiFi točka?", :icon => 'icon_drag', :load_icons => 'icon_drag')
    end
  end
  
  def create
    @spot = Spot.new params[:spot]
    
    @spot.lat = params[:lat].blank? ? DEFAULT_LAT : params[:lat]
    @spot.lng = params[:lng].blank? ? DEFAULT_LNG : params[:lng]
    @spot.zoom = params[:zoom].blank? ? DEFAULT_ZOOM : params[:zoom]
    
    # Create new user on the fly if necessary
    if logged_in?
      @spot.user = current_user
    # TODO Generate users here if we want to
    # else
    #   user = User.quick_create(params[:email])
    #   if user.valid?
    #     @spot.user = user
    #   else
    #     @map = initialize_google_map('map', @spot, :drag => true, :drag_title => "Kje se nahaja WiFi točka?", :icon => 'icon_drag', :load_icons => 'icon_drag')
    #     flash[:error] = "E-mail ki ste ga vnesli je že registriran. Če ste vi lastnik, potem <a href='/login' title='Prijavi se'>se prijavite</a>."
    #     render :action => 'new'
    #     return
    #   end
    end
    
    if @spot.save
      flash[:notice] = "WiFi točka je bila dodana! Hvala za pomoč!"
      redirect_to spot_url(@spot)
    else
      @map = initialize_google_map('map', @spot, :icon => 'icon_drag', :drag => true, :drag_title => "Kje se nahaja WiFi točka?", :load_icons => 'icon_drag')
      @user = user
      render :action => 'new'
    end
  end
  
  def edit
    edit! do
      @map = initialize_google_map('map', @spot, :icon => 'icon_drag', :drag => true, :drag_title => "Kje se nahaja WiFi točka?", :load_icons => 'icon_drag')
      @map.center_zoom_init(GLatLng.new(@spot.latlng), @spot.zoom)
    end
  end
  
  def update
    @spot = Spot.find params[:id]
    
    unless (params[:lat].empty? && params[:lng].empty? && params[:zoom].empty?)
      @spot.lat = params[:lat]
      @spot.lng = params[:lng]
      @spot.zoom = params[:zoom]
    end

    @spot.updated_by = current_user || "Neznanec (#{request.remote_ip})"
    
    update! {
      flash[:notice] = "Podatki za WiFi točko so bili posodobljeni."
      spot_path(@spot)
    }
  end
  
  def revert
    if params[:version]
      @spot = Spot.find params[:id]
      @spot.updated_by = current_user
      @spot.revert_to!(params[:version].to_i)
      flash[:notice] = "Verzija točke zamenjana."
    else
      flash[:notice] = "Nepravilna verzija."
    end
    redirect_to @spot
  end
  
  def delete
    @spot = Spot.find params[:id]
    @spot.delete
    flash[:notice] = "WiFi točka je bila odstranjena!"
    redirect_to spots_path
  end
  
  def destroy
    @spot = Spot.find params[:id]
    @spot.destroy!
    flash[:notice] = "WiFi točka je bila odstranjena (tudi iz baze)!"
    redirect_to spots_path
  end  
  
  def import
    Spot.import_from_rss
    flash[:notice] = "Točke so bile importirane iz RSS vira!"
    redirect_to spots_path
  end

  
  private ########################################
  
    def authorize
      if current_user
        spot = Spot.find params[:id]
        unless spot.user_id == current_user.id || current_user.admin?
          store_location
          flash[:notice] = "Nimate pravic za ogled te strani!"
          redirect_to root_path
          return false
        end
      else
        store_location
        flash[:notice] = "Za ogled strani morate biti prijavljeni!"
        redirect_to login_path
        return false
      end
    end
    
    def require_admin
      if current_user
        unless current_user.admin?
          flash[:notice] = "Nimate pravic za ogled te strani!"
          redirect_to root_path
          return false
        end
      else
        store_location
        flash[:notice] = "Za ogled strani morate biti prijavljeni!"
        redirect_to login_path
        return false
      end
    end
   
    def collection
      @spots ||= end_of_association_chain.all.paginate :page => params[:page], :per_page => 20
    end
    
    def ensure_friendly_url
      # FIXME Loading @spot is unnecessary if we could call this method after inherited_resources does the magic :P
      #       We now probably have two Spot.find for show action
      @spot ||= Spot.find params[:id]
      redirect_to @spot, :status => :moved_permanently unless @spot.friendly_id_status.best?
    end
  
end
