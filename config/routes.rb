ActionController::Routing::Routes.draw do |map|
  
  map.root :controller => 'spots', :action => 'index'
  
  map.connect '/home', :controller => 'page', :action => 'home'

  map.resources :categories
  map.resources :spots, :collection => { :import => :post }, :member => { :delete => :delete }
  
  map.resources :cities
                        
  map.resources :users, :member => { :contact => :any }
  map.resources :user_sessions
  
  
  map.signup '/signup', :controller => 'users',         :action => 'new'
  map.login  '/login',  :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'  

  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
