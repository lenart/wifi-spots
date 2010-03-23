class PageController < ApplicationController
  
  layout 'frontpage'
  
  def home
    @search = Search.new params
  end
  
end
