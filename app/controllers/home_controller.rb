class HomeController < ApplicationController
  def index

    if !flash[:error].nil?
      @users = User.all
      return
    end

    if current_user.nil?
      @users = User.all
      return
    end

    if current_user.admin?
      redirect_to professionals_path
    elsif current_user.professional?
      redirect_to professional_path current_user.professional
    end
  end

  def privacy
    render 'privacy'
  end
end
