Periop::Application.routes.draw do
  devise_for :patients

  resources :questions

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
  resources :doctors
  resources :patients

end
