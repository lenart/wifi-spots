# encoding: utf-8
class UsersController < ApplicationController
  
  before_filter :require_user, :only => :index
  before_filter :authorize, :only => [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end
  
  def show
    @user = User.find params[:id]
  end

  def new
    @user = User.new
  end
 
  def create
    @user = User.new(params[:user])
    
    if @user.save
      # OPTIMIZE Move this into an observer
      UserMailer.signup_notification(@user).deliver
      flash[:notice] = "Zahvaljujemo se vam za registracijo!"
      redirect_to @user
    else
      flash[:error]  = "Žal nismo uspeli ustvariti računa s temi podatki!"
      render :action => 'new'
    end
  end
  
  def edit
    @user = User.find params[:id] # allow admins to edit user (otherwise we could use current_user)
  end
  
  def update
    @user = User.find params[:id]
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "Vaš profil je bil posodobljen."
      redirect_to user_path(@user)
    else
      render :action => 'edit'
    end
  end
  
  
  private ########################################
  
    def authorize
      if current_user
        # FIXME This doesn't work for index action (no user id in the params)
        user = User.find params[:id]
        unless user == current_user || current_user.admin?
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
  
end