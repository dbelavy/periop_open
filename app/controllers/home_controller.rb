class HomeController < ApplicationController
  def index
    if current_user.nil?
    @users = User.all
    return
    end

    if current_user.admin_role?
      redirect_to admin_path
    elsif current_user.doctor_role?
      redirect_to doctor_path
    elsif current_user.patient_role?
      redirect_to patient_path(current_user.patient)
    end
  end
end
