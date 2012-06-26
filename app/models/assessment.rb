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

  embeds_many :answers
  accepts_nested_attributes_for :answers, reject_if: :all_blank


  def self.create_for_patient(form, patient)
    assessment = self.create!(:name => form.name,)
    assessment.form= form
    assessment.patient= patient
    assessment.save!
    assessment
  end

  def answer question
    result = answers.where(:question_id => question._id).first
  end

  def self.status_list
    [NOT_STARTED, STARTED_BUT_INCOMPLETE, COMPLETE]
  end

  def update_assessment params
    result = true
    if result
      result = update_attributes(params)
    end
  end
end
