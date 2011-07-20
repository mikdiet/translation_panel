Rails.application.routes.draw do
  namespace :translations do
    resources :translations, :only => :new
  end
end