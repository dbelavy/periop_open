class PatientsController < ApplicationController

  before_filter :create_patient_from_params, :only => :create
  load_and_authorize_resource

  def show
  end

  def index
    @patients = @patients.paginate(:page => params[:page])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: PatientsDatatable.new(view_context,current_ability)}
    end
  end

  def setup_assessment assessment
    assessment.form.questions.sorted.each do |q|
      if !q.nil?
        if assessment.answer(q).nil?
          assessment.answers_attributes= [{:question => q}]
        end
      end
    end
    return assessment
  end

  def new
    @patient = Patient.new
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
    patient_params = params[:patient]
    assessment_params = params[:patient].delete(:assessment)
    is_updated = @patient.new_patient_assessment.update_assessment(assessment_params,current_user)
    is_updated = is_updated && @patient.update_attributes(patient_params)
    if is_updated
      @patient.update_values
    end
    respond_to do |format|
      if is_updated
        format.html { redirect_to @patient, notice: 'Patient was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end


  def create_patient_from_params
    patient_params = params[:patient].clone
    patient_params.delete(:assessment)
    @patient = Patient.new(patient_params)
  end

  # POST /patients
  # POST /patients.json
  def create
    assessment_params = params[:patient].delete(:assessment)
    is_updated = @patient.new_patient_assessment.update_assessment(assessment_params,current_user)
    if is_updated
      @patient.update_values
    end
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
