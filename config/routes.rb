Periop::Application.routes.draw do

  constraints(:host => "pre-op.net") do
    match "(*x)" => redirect {|params, request|
      URI.parse(request.url).tap { |x| x.host = "www.#{x.host}" }.to_s
    }
  end

  resources :categories

  resources :forms
  resources :concepts

  get 'contact' => "contact_mails#new"
  post 'contact' => "contact_mails#create"

  #devise_for :patients, :path_prefix => 'd'

  resources :patients do
    resources :assessments ,:only => [:edit,:update,:show,:unassigned,:index,:create] do
      get 'unassigned', :on => :collection
      put 'unassigned', :on => :collection
      put 'assign'
      put 'unassign'
    end
    get 'operation_assessment_form' => 'assessments#operation_assessment_form'
    get 'clinician_assessment_form' => 'assessments#clinician_assessment_form'
    get 'loading_screen' => 'assessments#loading_screen'
    get 'note_assessment_form'      => 'assessments#note_assessment_form'
    resource :summary, :only => [:show,:show_printable] do
      get 'show_printable'
    end
  end



  resources :assessments ,:only => [:show,:destroy,:patient_assessment_form] do
    get "unassigned" => "assessments#unassigned",:on => :collection
    resource :assessment_summary,:as => :summary ,:only => [:show,:show_printable] do
      get 'show_printable'
    end
  end
  get "patient_assessment_form" => "assessments#patient_assessment_form"
  post "patient_assessment_form" => "assessments#update_patient_assessment"
  #post "operation_assessment_form" => "assessments#update_operation_assessment"

  resources :questions

  resources :professionals do
    post 'reset_password', :on => :member
  end


  authenticated :user do
    root :to => 'home#index'
  end

  root :to => "home#index"

  get 'privacy' => "home#privacy"
  get 'tos' => "home#tos"

  if (Rails.application.config.registerable)
    devise_for :users ,:controllers => {:registrations => "registrations"}
  else
    devise_for :users, :skip => [:registrations]
        as :user do
          get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
          put 'users' => 'devise/registrations#update', :as => 'user_registration'
        end
  end

  resources :users, :only => [:show, :index]

end