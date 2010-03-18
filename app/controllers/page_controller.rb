class PageController < ApplicationController
  
  def home
    @spots = Spot.recent
    @cities = City.all
  end
  
end
