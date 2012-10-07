class Form
  include Mongoid::Document
  field :name, :type => String
  field :person_role, :type => Array
  has_and_belongs_to_many :questions, inverse_of: nil

  PATIENT_ASSESSMENT = "Patient assessment"
  TELEPHONE_ASSESSMENT = "Telephone assessment"
  CLINIC_ASSESSMENT = "Clinic assessment"
  NEW_PATIENT = "New patient"

  def self.patient_form
    self.find_by_name PATIENT_ASSESSMENT
  end

  def self.new_patient_form
    self.find_by_name NEW_PATIENT
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