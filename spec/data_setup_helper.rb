require 'spec_helper'
include ApplicationHelper

def setup_anesthetist
  anesthetist_user = create(:professional_user)
  anesthetist = anesthetist_user.professional
  anesthetist.name = Faker::Name.last_name
  anesthetist.speciality = Professional::ANESTHETIST
  anesthetist.save
  anesthetist
end


def doctor_patient_form professional
  patient_form = create(:form,name: Form::PATIENT_ASSESSMENT,professional_name: professional.name)
  patient_form.questions = setup_questions
  patient_form.questions.push(create_question_with_concept('doctor specific ' + professional.name))
  patient_form.save!
end


def setup_assistant
  @assistant_user = create(:professional_user)
  @assistant = @assistant_user.professional
  # important! it is stored as plain string
  @assistant.shared_professionals_ids = [@anesthetist.id.to_s]
  @assistant.save!
end

def create_question_with_concept concept_name
  c = create(:concept, name: concept_name)
  q = create(:question,concept: c,display_name: concept_name )
end

 PATIENT_ASSESSMENT_CONCEPTS  = %w(patient_first_name patient_middle_name patient_surname patient_dob
medicare_card_number medicare_card_number_identifier individual_healthcare_identifier
anesthetist procedure_date_patient_reported referring_surgeon)

def setup_questions
  result = []
  PATIENT_ASSESSMENT_CONCEPTS.each do |concept|
    result << create_question_with_concept(concept)
  end
  result
end

def fill_patient_assessment_data suffix
  result = {}
  PATIENT_ASSESSMENT_CONCEPTS.each do |concept|
    result[concept] = concept + '_'+ suffix
  end
  result
end


def default_patient_form
  if @patient_form.nil?
    @patient_form = create(:form,name: Form::PATIENT_ASSESSMENT)
    @patient_form.questions = setup_questions
  end
  @patient_form
end

require_relative '../app/helpers/application_helper'

def setup_patient_assessment anesthetist
  assessment = Assessment.new
  assessment.form = default_patient_form
  assessment.anesthetist_id = anesthetist.id

  setup_assessment assessment
  answer = assessment.find_answer_by_concept_name "patient_first_name"
  answer.value = "John"
  answer.save!
  answer = assessment.find_answer_by_concept_name "anesthetist"
  answer.id_value = anesthetist.id
  assessment.save!
  assessment
end
