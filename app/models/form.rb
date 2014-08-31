class Form
  include Mongoid::Document

  cache

  field :name, :type => String
  field :person_role, :type => Array

  field :professional_id, :type => String
  has_and_belongs_to_many :questions, inverse_of: nil

  PATIENT_ASSESSMENT = "Patient assessment"
  TELEPHONE_ASSESSMENT = "Telephone assessment"
  CLINIC_ASSESSMENT = "Clinic assessment"
  QUICK_NOTE_ASSESSMENT = "Quick note"
  NEW_PATIENT = "New patient"
  NEW_OPERATION = "New Operation"

  def self.patient_form professional_slug
    professional = Professional.find_by_slug professional_slug
    result = self.where(name: PATIENT_ASSESSMENT,professional_id: professional).first
    if result.nil?
      result = self.where(name: PATIENT_ASSESSMENT).first
    end
    result
  end

  def self.new_patient_form
    self.find_by_name NEW_PATIENT
  end

  def self.new_operation_form
    self.find_by_name NEW_OPERATION
  end

  def self.find_by_name name
    self.where(name: name).first
  end

  def sorted_questions
    self.questions
  end

  def clear_questions
    self.question_ids =[]
    self.save!
  end

  def patient_form?
    name == PATIENT_ASSESSMENT
  end


end