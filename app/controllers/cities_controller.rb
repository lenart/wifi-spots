# encoding: utf-8
class CitiesController < ApplicationController
  
  before_filter :ensure_current_city_url, :only => :show
  
  def index
    # FIXME Why the fuck is default_scope not working??
    @cities = City.all :order => 'name asc'
  end

  def show
    @distance = params[:distance] || 30
    
    @city = City.find params[:id]
    @spots = @city.spots(:conditions => {:deleted=>false}, :within => @distance)
    
    @search = Search.new params
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @spots }
    end
  end
  
  
  
  private
  
    def ensure_current_city_url
      # FIXME This is unnecessary if we could call this method after inherited_resources does the magic :P
      @city = City.find params[:id]
      redirect_to @city, :status => :moved_permanently unless @city.friendly_id_status.best?
    end
  
  
end
