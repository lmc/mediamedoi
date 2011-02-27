Mediamedoi::Application.routes.draw do
  resources :media_libraries do
    collection do
      get :convert
    end
  end
end
