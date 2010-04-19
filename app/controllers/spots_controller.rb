class SpotsController < InheritedResources::Base
  
  # before_filter :require_user, :only => [:edit, :update, :destroy]
  # before_filter :authorize, :only => [:edit, :update, :destroy]
  before_filter :require_admin, :only => [:revert, :restore, :delete, :destroy]
  before_filter :ensure_friendly_url, :only => :show
  
  rescue_from 'Search::EmptyQuery' do
    redirect_to(root_path, :status => 302)
  end
  
  rescue_from 'Search::NoResults' do |e|
    # TODO Ce v bliznji okolici ni tock, potem ni nujno da je napacna geolokacija (primer: kotlje)
    unless e.geo_search
      flash[:notice] = "Ni rezultatov, ki ustrezajo iskalnemu kriteriju: <strong>#{e.query}</strong>."
      redirect_to(root_path)
    else
      flash[:notice] = "<strong>Opozorilo:</strong> Niz <strong>#{e.query}</strong> smo poskusili geolocirati vendar iskanje ni vrnilo rezultatov. Poskušam še iskanje brez geolokacije."
      flash.keep
      redirect_to(spots_path + "?q=#{e.query}&geo=false")
    end
  end
  
  rescue_from 'Search::NoGeoLocation' do |e|
    flash[:notice] = "Nismo uspeli dobiti podatkov o vnešeni lokaciji: <strong>#{e.address}</strong>."
  end
  
  def index
    @search = Search.new params
    @spots = @search.run # we don't want anyone to access index without search string
    
    respond_to do |format|
      format.html do
        @map = initialize_google_map("map", nil, :load_icons => "icon_spot, icon_green")

        markers = create_spots_markers(@spots)
        
        # Add reference point for geolocated search
        markers << GMarker.new([@search.location.lat, @search.location.lng],
                               :icon => Variable.new("icon_green"), :title => "Izhodišče iskanja") if @search.location && @search.location.success

        clusterer = Clusterer.new(markers, :max_visible_markers => 50)
        @map.overlay_init clusterer

        @bounds = bounding_box_corners(markers)
        @map.center_zoom_on_bounds_init(GLatLngBounds.new(@bounds.first, @bounds.last))
      end
      format.xml { render :xml => @spots }
    end
  end
  
  def show
    show! {
      @map = initialize_google_map('map', @spot, :icon => "icon_spot", :title => @spot.title, :zoom => @spot.zoom)
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
    
    if @spot.save && captcha_valid?
      flash[:notice] = "WiFi točka je bila dodana! Hvala za pomoč!"
      redirect_to spot_url(@spot)
    else
      @map = initialize_google_map('map', @spot, :icon => 'icon_drag', :drag => true, :drag_title => "Kje se nahaja WiFi točka?", :load_icons => 'icon_drag')
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
    
    if @spot.update_attributes(params[:spot]) && captcha_valid?
      flash[:notice] = "Podatki za WiFi točko so bili posodobljeni."
      redirect_to spot_path(@spot)
    else
      render :action => 'edit'
    end
  end
  
  # Revert to an earlier spot version
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
  
  # Undelete spot
  def restore
    @spot = Spot.find params[:id]
    @spot.restore
    flash[:notice] = "Točka ni več izbrisana."
    redirect_to @spot
  end
  
  def delete
    @spot = Spot.find params[:id]
    if captcha_valid?
      @spot.delete(params[:spot][:reason])
    
      if @spot.valid?
        flash[:notice] = "WiFi točka je bila odstranjena!"
        redirect_to spots_path
      else
        flash[:error] = "Za izbris moraš navesti razlog."
        redirect_to @spot
      end
    else
      flash[:error] = "reCaptcha ni bila pravilno prepisana!"
      redirect_to @spot
    end
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
    
    def captcha_valid?
      verify_recaptcha(:model => @spot, :message => "Ojoj! Napačno si prepisal-a reCaptcha znake. Poskusi še enkrat!")
    end
  
end
