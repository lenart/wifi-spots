Wifitocke::Application.routes.draw do  
  root to: 'page#home'

  resources :categories
  resources :spots do
    collection do
      post :import
    end
    member do
      put :restore
      put :delete
      put :revert
    end
  end

  resources :cities
  resources :users do
    member do
      get :contact
      post :contact
    end
  end

  resources :user_sessions
  
  match '/signup' => 'users#new', :as => :signup
  match '/login' => 'user_sessions#new', :as => :login
  match '/logout' => 'user_sessions#destroy', :as => :logout

  # What are these?
  match '/cities' => 'cities#index'
  match '/categories' => 'categories#index'
  match '/spots' => 'spots#index'
  match '/spots/:id' => 'spots#show', :id => :id
  match '/cities/:id' => 'cities#show', :id => :id
  match '/categories/:id' => 'categories#show', :id => :id  
end