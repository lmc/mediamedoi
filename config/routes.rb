Mediamedoi::Application.routes.draw do
  resources :conversion_queue_items, :only => [:index]

  resources :media_libraries do
    collection do
      get :convert
    end
  end

  resources :hosts, :only => [:index]

end
