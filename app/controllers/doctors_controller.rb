class DoctorsController < ApplicationController
  
  def show
    @doctor = Doctor.find(params[:id])
  end

  def index
    @doctors = Doctor.paginate(:page => params[:page])
  end

  
end
