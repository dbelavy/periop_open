Periop::Application.routes.draw do

  devise_for :patients, :path_prefix => 'd'

  resources :patients

  resources :questions

  resources :professionals do
    post 'reset_password', :on => :member
  end


  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]



end
