class Assessment
  include Mongoid::Document

  NOT_STARTED = 'not started'
  STARTED_BUT_INCOMPLETE = 'Started but incomplete'
  COMPLETE = 'Complete'


  field :status, :type => String, :default => NOT_STARTED
  field :date_started, :type => Date
  belongs_to :patient
  belongs_to :form

end
