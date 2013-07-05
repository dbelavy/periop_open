class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    logger.debug("flash[:error] = " + exception.message.inspect)
    redirect_to root_url
  end

   def current_ability
     @current_ability ||= Ability.new(current_user)
   end

end
