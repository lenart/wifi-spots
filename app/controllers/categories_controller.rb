class CategoriesController < InheritedResources::Base
  
  before_filter :authorize, :except => [:index, :show]
  
  def show
    show! do 
      @spots = @category.spots.paginate :per_page => 400, :page => params[:page]
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
