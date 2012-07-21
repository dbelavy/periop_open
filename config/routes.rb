Periop::Application.routes.draw do

  resources :categories

  resources :forms
  resources :concepts

  #devise_for :patients, :path_prefix => 'd'

  resources :patients do
    resources :assessments ,:only => [:edit,:update,:show,:unassigned] do
      get 'unassigned', :on => :collection
      put 'unassigned', :on => :collection
      put 'assign'
      put 'unassign'

    end
    resource :summary, :only => [:show]
  end



  resources :assessments ,:only => [:show,:destroy,:patient_assessment_form] do
    get "unassigned" => "assessments#unassigned",:on => :collection
  end
  get "patient_assessment_form" => "assessments#patient_assessment_form"
  post "patient_assessment_form" => "assessments#update_patient_assessment"

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