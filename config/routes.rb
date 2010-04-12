ActionController::Routing::Routes.draw do |map|
  # map.root :controller => 'spots', :action => 'index'
  
  map.connect '/home', :controller => 'page', :action => 'home'

  map.resources :categories, :as => 'kategorija'
  
  map.resources :spots, :as => 'tocka',
                :collection => { :import => :post },
                :member => { :delete => :put, :revert => :put, :restore => :put }
  
  map.resources :cities, :as => 'mesto'

  map.root :controller => 'page', :action => 'home' 
                        
  map.resources :users, :member => { :contact => :any }
  map.resources :user_sessions
  
  map.signup '/signup', :controller => 'users',         :action => 'new'
  map.login  '/login',  :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'  
  
  # Support old routes
  map.connect '/spots/:id', :controller => 'spots', :action => 'show', :id => :id
  map.connect '/cities/:id', :controller => 'cities', :action => 'show', :id => :id
  map.connect '/categories/:id', :controller => 'categories', :action => 'show', :id => :id

  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
