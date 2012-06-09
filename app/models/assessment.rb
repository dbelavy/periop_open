class Assessment
  include Mongoid::Document

  NOT_STARTED = 'not started'
  STARTED_BUT_INCOMPLETE = 'Started but incomplete'
  COMPLETE = 'Complete'


  field :status, :type => String, :default => NOT_STARTED
  field :date_started, :type => Date
  field :name, :type => String
  belongs_to :patient
  belongs_to :form

  def self.create_for_patient(form, patient)
    assessment = self.create!(:name => form.name,)
    assessment.form= form
    assessment.patient= patient
    assessment.save!
    assessment
  end

end
