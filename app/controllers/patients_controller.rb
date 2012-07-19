class PatientsController < ApplicationController
  load_and_authorize_resource

  def show
    #@patient = Patient.find(params[:id])
  end

  def index
    @patients = @patients.paginate(:page => params[:page])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: PatientsDatatable.new(view_context)}
    end
  end

  def new
    @patient = Patient.new
    @assessment = @patient.new_patient_assessment
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @patient }
    end
  end

  # GET /patients/1/edit
  def edit
    @patient = Patient.find(params[:id])
  end

  # PUT /patients/1
  # PUT /patients/1.json
  def update
    @patient = Patient.find(params[:id])

    respond_to do |format|
      if @patient.update_attributes(params[:patient])
        format.html { redirect_to @patient, notice: 'Patient was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /patients
  # POST /patients.json
  def create
    @patient = Patient.new(params[:patient])
    @patient.new_patient_assessment.update_attributes(params[:patient][:assessment])
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
