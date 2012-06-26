class AssessmentsController < ApplicationController
  #load_and_authorize_resource
  # GET /assessments
  # GET /assessments.json
  def index
    @assessments = Assessment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assessments }
    end
  end

  # GET /assessments/1
  # GET /assessments/1.json
  def show
    @assessment = Assessment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assessment }
    end
  end

  # GET /assessments/new
  # GET /assessments/new.json
  def new
    @assessment = Assessment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assessment }
    end
  end

  # GET /assessments/1/edit
  def edit
    @assessment = Assessment.find(params[:id])
    @questions = @assessment.form.questions
    @patient = Patient.find(params[:patient_id])
  end

  # GET /assessments/edit_patient
  def edit_patient
    @patient = current_patient
    patientForm = Form.where(name: "Patient assessment")
    @assessment = current_patient.assesments.where(:status => Assessment::NOT_STARTED,form:  patientForm)
    @questions = @assessment.form.questions
  end


  # POST /assessments
  # POST /assessments.json
  def create
    @assessment = Assessment.new(params[:assessment])

    respond_to do |format|
      if @assessment.save
        format.html { redirect_to @assessment, notice: 'Assessment was successfully created.' }
        format.json { render json: @assessment, status: :created, location: @assessment }
      else
        format.html { render action: "new" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assessments/1
  # PUT /assessments/1.json
  def update
    @assessment = Assessment.find(params[:id])

    respond_to do |format|
      if @assessment.update_assessment (params[:assessment])
        format.html { redirect_to patient_assessment_path, notice: 'Assessment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assessments/1
  # DELETE /assessments/1.json
  def destroy
    @assessment = Assessment.find(params[:id])
    @assessment.destroy

    respond_to do |format|
      format.html { redirect_to assessments_url }
      format.json { head :no_content }
    end
  end
end
