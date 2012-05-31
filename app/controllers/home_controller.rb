class HomeController < ApplicationController
  def index

    if !flash[:error].nil?
      @users = User.all
      return
    end

    if patient_signed_in?
      redirect_to patient_path(current_patient)
    end

    if current_user.nil?
      @users = User.all
      return
    end

    if current_user.admin?
      redirect_to users_path
    elsif current_user.doctor?
      redirect_to doctor_path current_user.doctor
    end
  end
end
