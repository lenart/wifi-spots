# encoding: utf-8
class SpotsController < InheritedResources::Base
  
  # before_filter :require_user, :only => [:edit, :update, :destroy]
  # before_filter :authorize, :only => [:edit, :update, :destroy]
  before_filter :require_admin, :only => [:revert, :restore, :delete, :destroy]
  before_filter :ensure_friendly_url, :only => :show
  
  rescue_from 'Search::EmptyQuery' do
    redirect_to root_path
  end
  
  rescue_from 'Search::NoResults' do |e|
    # TODO Ce v bliznji okolici ni tock, potem ni nujno da je napacna geolokacija (primer: kotlje)
    unless e.geo_search
      flash[:notice] = "Ni rezultatov, ki ustrezajo iskalnemu kriteriju: <strong>#{e.query}</strong>.".html_safe
      redirect_to(root_path)
    else
      flash[:notice] = "<strong>Opozorilo:</strong> Niz <strong>#{e.query}</strong> smo poskusili geolocirati vendar iskanje ni vrnilo rezultatov. Poskušam še iskanje brez geolokacije.".html_safe
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
      format.html
      format.xml { render :xml => @spots }
    end
  end
  
  def new
    @spot = Spot.new
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
    
    if @spot.valid? && captcha_valid?
      @spot.save
      flash[:notice] = "WiFi točka je bila dodana! Hvala za pomoč!"
      redirect_to spot_url(@spot)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @spot = Spot.find params[:id]
  end
  
  def update
    @spot = Spot.find params[:id]
    
    unless (params[:lat].empty? && params[:lng].empty? && params[:zoom].empty?)
      @spot.lat = params[:lat]
      @spot.lng = params[:lng]
      @spot.zoom = params[:zoom]
    end

    # @spot.updated_by = current_user || "Neznanec (#{request.remote_ip})"
    @spot.attributes = params[:spot]
    
    if @spot.valid? && captcha_valid?
      @spot.save
      flash[:notice] = "Podatki za WiFi točko so bili posodobljeni."
      redirect_to spot_path(@spot)
    else
      render :action => 'edit'
    end
  end
  
  # Revert to an earlier spot version
  def revert
    # if params[:version]
    #   @spot = Spot.find params[:id]
    #   @spot.updated_by = current_user
    #   @spot.revert_to!(params[:version].to_i)
    #   flash[:notice] = "Verzija točke zamenjana."
    # else
    #   flash[:notice] = "Nepravilna verzija."
    # end
    flash[:error] = "Revert tock ni implementiran"
    redirect_to @spot
  end
  
  # Undelete spot
  def restore
    # @spot = Spot.find params[:id]
    # @spot.restore
    # flash[:notice] = "Točka ni več izbrisana."
    flash[:error] = "Restore tock ni implementiran"
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
      return true if logged_in?
      verify_recaptcha(:model => @spot, :message => "Ojoj! Napačno si prepisal-a reCaptcha znake. Poskusi še enkrat!")
    end
  
end
