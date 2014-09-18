class Form
  include Mongoid::Document

  cache

  field :name, :type => String
  field :person_role, :type => Array

  field :professional_id, :type => String
  field :professional_name, :type => String
  has_and_belongs_to_many :questions, inverse_of: nil

  PATIENT_ASSESSMENT = "Patient assessment"
  TELEPHONE_ASSESSMENT = "Telephone assessment"
  CLINIC_ASSESSMENT = "Clinic assessment"
  QUICK_NOTE_ASSESSMENT = "Quick note"
  NEW_PATIENT = "New patient"
  NEW_OPERATION = "New Operation"

  def self.patient_form professional_slug
    patient_form_by_professional_name(Professional.slug_to_name(professional_slug))
  end

  def self.patient_form_by_professional_name professional_name
    form = self.where(name: PATIENT_ASSESSMENT, professional_name: professional_name).first
    if form.nil?
      form = self.where(name: PATIENT_ASSESSMENT, professional_name: nil).first
    end
    form
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

private
  def self.patient_form_by_professional(professional)
    professional_id = nil
    professional_id = professional._id if !professional.nil?
    form = self.where(name: PATIENT_ASSESSMENT, professional_id: professional_id).first
    if form.nil?
      form = self.where(name: PATIENT_ASSESSMENT, professional_id: nil).first
    end
    form
  end
end
