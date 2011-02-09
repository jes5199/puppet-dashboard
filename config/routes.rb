PuppetDashboard::Application.routes.draw do
  resources :node_classes do
  
  
      resources :nodes
  end

  resources :node_groups do
  
  
      resources :nodes
  end

  resources :nodes do
    collection do
  get :search
  get :unreported
  get :no_longer_reporting
  get :hidden
  end
    member do
  get :reports
  get :facts
  put :hide
  put :unhide
  end
  
  end

  resources :reports do
    collection do
  get :search
  end
  
  
  end

  match 'reports/upload' => 'reports#upload', :as => :upload, :via => post
  match '/release_notes' => 'pages#release_notes', :as => :release_notes
  match '/' => 'pages#home'
  match '/:controller(/:action(/:id))'
end
