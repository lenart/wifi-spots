ActionController::Routing::Routes.draw do |map|
  # map.root :controller => 'spots', :action => 'index'
  map.root :controller => 'page', :action => 'home' 
  
  map.connect '/home', :controller => 'page', :action => 'home'

  map.resources :categories, :as => 'kategorije'
  
  map.resources :spots, :as => 'tocke',
                :collection => { :import => :post },
                :member => { :delete => :put, :revert => :put, :restore => :put }
  
  map.resources :cities, :as => 'mesta'
                        
  map.resources :users, :member => { :contact => :any }
  map.resources :user_sessions
  
  map.signup '/signup', :controller => 'users',         :action => 'new'
  map.login  '/login',  :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'  
  
  # Support old routes
  map.connect '/cities', :controller => 'cities', :action => 'index'
  map.connect '/categories', :controller => 'categories', :action => 'index'
  map.connect '/spots', :controller => 'spots', :action => 'index'
  
  map.connect '/spots/:id', :controller => 'spots', :action => 'show', :id => :id
  map.connect '/cities/:id', :controller => 'cities', :action => 'show', :id => :id
  map.connect '/categories/:id', :controller => 'categories', :action => 'show', :id => :id
  
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
