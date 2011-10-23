# encoding: utf-8

class ApplicationController < ActionController::Base

  include InheritedResources::DSL

  # helper :all # include all helpers, all the time
  helper_method :logged_in?, :current_user, :local_request?

  # Hide these fields in logs
  # filter_parameter_logging :password, :password_confirmation

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ec26ea81e88e7b79838fcdf43774e96d'

  private #################################################################################

    def user_for_paper_trail
      logged_in? ? current_user : 'Public user'
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def logged_in?
      current_user
    end
    
    def require_user
      unless current_user
        store_location
        flash[:notice] = "Za ogled te strani morate biti prijavljeni!"
        redirect_to login_path
        return false
      end
    end
    
    def require_no_user
      if current_user
        store_location
        flash[:notice] = "Stran je namenjena neregistriranim uporabnikom!"
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def local_request?
      Rails.env == :development
    end
  
end
