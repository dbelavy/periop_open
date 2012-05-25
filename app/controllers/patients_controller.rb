class PatientsController < ApplicationController
  load_and_authorize_resource

  def show
    @patient = Patient.find(params[:id])
  end

  def index
    @patients = Patient.paginate(:page => params[:page])
  end

end
