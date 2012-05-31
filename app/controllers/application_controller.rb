class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

   def current_ability
     # instead of Ability.new(current_user)
     if patient_signed_in?
       @current_ability ||= Ability.new(current_patient)
     else
       @current_ability ||= Ability.new(current_user)
     end
   end

end
