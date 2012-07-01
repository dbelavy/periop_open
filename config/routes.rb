Periop::Application.routes.draw do

  resources :forms
  resources :concepts

  #devise_for :patients, :path_prefix => 'd'

  resources :patients do
    resources :assessments ,:only => [:index,:edit,:update,:show,:unassigned] do
      get 'unassigned', :on => :collection
      put 'unassigned', :on => :collection
      put 'assign'
    end
  end

  get "patient_assessment_form" => "assessments#patient_assessment_form",
      :as => "patient_assessment_form"
  post "patient_assessment_form" => "assessments#update_patient_assessment",
      :as => "patient_assessment_form"

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