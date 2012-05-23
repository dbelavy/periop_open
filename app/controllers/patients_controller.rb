class PatientsController < ApplicationController

  def show
    @patient = Patient.find(params[:id])
  end

  def index
    @patients = Patient.paginate(:page => params[:page])
  end

end
