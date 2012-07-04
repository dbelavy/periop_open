class Form
  include Mongoid::Document
  field :name, :type => String
  field :person_role, :type => Array
  has_and_belongs_to_many :questions, inverse_of: nil

  PATIENT_ASSESSMENT = "Patient assessment"
  TELEPHONE_ASSESSMENT = "Telephone assessment"
  CLINIC_ASSESSMENT = "Clinic assessment"

  def self.patientForm
    Form.where(name: PATIENT_ASSESSMENT ).first
  end

end
