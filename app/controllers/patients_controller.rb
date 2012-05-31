class PatientsController < ApplicationController
  load_and_authorize_resource

  def show
    @patient = Patient.find(params[:id])
  end

  def index
    @patients = Patient.paginate(:page => params[:page])
  end

  def new
    @patient = Patient.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @patient}
    end
  end
  
  # POST /patients
  # POST /patients.json
  def create
    @patient = Patient.new(params[:patient])
    password = @patient.dob.to_s
    @patient.password= password
    @patient.password_confirmation= password
    logger.debug 'created patient ' + @patient.to_yaml
    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: 'Patient was successfully created.' }
        format.json { render json: @patient, status: :created, location: @patient }
      else
        format.html { render action: "new" }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end
  
end
