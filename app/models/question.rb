class Question
  include Mongoid::Document
  field :question_type, :type => String
  field :display_conditions, :type => String
  field :short_name, :type => String
  field :clinical_terms, :type => String
  field :question_for_patient, :type => String
  field :compulsory_for_patient_reported_assessment, :type => String
  field :input_type, :type => String
  field :option_list, :type => String
  field :used_in_patient_assesment, :type => String
  field :used_in_phone_assesment, :type => String
  field :snomed_concept, :type => String
end
