class AssessmentsController < ApplicationController
  load_resource :patient,:except => [:patient_assessment_form,:update_patient_assessment]
  load_and_authorize_resource :assessment,:new => [:patient_assessment_form,:update_patient_assessment]
  #, :through => :patient


  # GET /patient/.id/assessments/unassigned.json
  def unassigned
    if !params[:patient_id].nil?
      @patient = Patient.find(params[:patient_id])
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: AssessmentsDatatable.new(view_context,current_ability)}
    end
  end

  def index
    if !params[:patient_id].nil?
      @patient = Patient.find(params[:patient_id])
    end
    @assessments = Assessment.where(:patient_id => @patient._id).paginate(:page => params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assessments }
    end
  end


  # GET /assessments/1
  # GET /assessments/1.json
  def show
    #@assessment = Assessment.find(params[:id])
    #if !params[:patient_id].nil?
    #  @patient = Patient.find(params[:patient_id])
    #end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assessment }
    end
  end

  def summary
    #@patient = Patient.find(params[:patient_id])
    @concepts = Concept.all
    @assessments = @patient.assessments
    respond_to do |format|
      format.html
      format.json { render json: @assessment }
    end
  end

  # GET /assessments/new
  # GET /assessments/new.json
  def new
    #@assessment = Assessment.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assessment }
    end
  end

  # GET /assessments/1/edit
  def edit
    #@assessment = Assessment.find(params[:id])
    @questions = @assessment.form.questions
    #@patient = Patient.find(params[:patient_id])
  end

  # GET /patient_assessment_form
  def patient_assessment_form
    #@assessment = Assessment.new
    @assessment.form= Form.patient_form
    @questions = @assessment.form.questions
  end


  # PUT /assessments/1
  # PUT /assessments/1.json
  def update
    #@assessment = Assessment.find(params[:id])
    is_updated = @assessment.update_assessment(params[:assessment],current_user)
    respond_to do |format|
      if is_updated
        format.html { redirect_to patient_assessment_path, notice: 'Assessment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  def assign
    # TODO enable load_and_authorize
    @assessment = Assessment.find(params[:assessment_id])
    #@patient = Patient.find(params[:patient_id])
    @assessment.patient= @patient
    @patient.update_values
    respond_to do |format|
      if @assessment.save
        format.html { redirect_to patient_assessment_path(@patient, @assessment), notice: 'Assessment assigned.'}
        format.json { head :no_content }
      else
        format.html { render action: "show" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  def unassign
    @assessment = Assessment.find(params[:assessment_id])
    #@patient = Patient.find(params[:patient_id])
    @assessment.patient= nil
    @patient.update_values
    respond_to do |format|
      if @assessment.save
        format.html { redirect_to patient_assessment_path(@patient, @assessment), notice: 'Assessment unassigned.'}
        format.json { head :no_content }
      else
        format.html { render action: "show" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_patient_assessment
    #@assessment = Assessment.new(params[:assessment])
    @assessment.form= Form.patient_form
    @assessment.start_and_complete_assessment
    respond_to do |format|
      if @assessment.save
        anesthetist = @assessment.get_anesthetist
        if !anesthetist.nil?
          AssessmentMailer.patient_assessment_mail(anesthetist).deliver
        end
        format.html { redirect_to root_path, notice: 'Thank you, your assessment has been sent to your doctor.' }
        format.json { render json: @assessment, status: :created, location: @assessment }
      else
        format.html { render action: "patient_assessment_form" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /assessments/1
  # DELETE /assessments/1.json
  def destroy
    #@assessment = Assessment.find(params[:id])
    @assessment.destroy

    respond_to do |format|
      if @patient.nil?
        format.html {redirect_to root_path , notice: 'Assessment was successfully deleted.' }
        format.json { head :no_content }
      else
        format.html {redirect_to @patient, notice: 'Assessment was successfully deleted.' }
        format.json { head :no_content }
      end
    end
  end
end
