App::Application.routes.draw do
  namespace :admin do
    resources :translations, :only => :new
  end

  root :to => "home#index"
end
