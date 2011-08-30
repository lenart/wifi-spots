# encoding: utf-8
class UserSessionsController < ApplicationController

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    
    if @user_session.save
      flash[:notice] = "Uspešno ste se prijavili!"
      redirect_back_or_default root_url
    else
      render :action => :new
    end
  end
  
  def destroy
    if current_user_session
      current_user_session.destroy
      flash[:notice] = "Uspešno ste se odjavili!"
    end
    redirect_to root_url
  end
end