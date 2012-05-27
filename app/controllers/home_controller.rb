class HomeController < ApplicationController
  def index
    if current_user.nil?
    @users = User.all
    return
    end

    if current_user.admin?
      redirect_to users_path
    elsif current_user.doctor?
      redirect_to doctor_path current_user.doctor
    elsif current_user.patient?
      redirect_to patient_path(current_user.patient)
    end
  end
end
