ActionController::Routing::Routes.draw do |map|
  # map.root :controller => 'spots', :action => 'index'
  map.root :controller => 'page', :action => 'home' 
  
  map.connect '/home', :controller => 'page', :action => 'home'

  map.resources :categories, :as => 'kategorije'
  
  map.resources :spots, :as => 'tocke',
                :collection => { :import => :post },
                :member => { :delete => :put, :revert => :put, :restore => :put }
  
  map.resources :cities, :as => 'mesta'
                          
  map.login 'login',       :controller => :user_sessions, :action => :new
  map.logout 'logout',     :controller => :user_sessions, :action => :destroy, :conditions => {:method => :get}
  map.authenticate 'authenticate', :controller => :user_sessions, :action => :create, :conditions => {:method => :post}

  map.register 'register', :controller => :users, :action => :new
  map.signup 'signup',     :controller => :users, :action => :create, :conditions => {:method => :post}
  map.connected 'connect', :controller => :users, :action => :update, :conditions => {:method => :put}
  map.profile 'profile',   :controller => :users, :action => :show
  
  map.resources :users
  map.resource :user_session
  
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
