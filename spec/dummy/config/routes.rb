Dummy::Application.routes.draw do
  resources :news, :only => [:index, :show]
end
