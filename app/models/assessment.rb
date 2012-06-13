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

  def self.create_for_patient(form, patient)
    assessment = self.create!(:name => form.name,)
    assessment.form= form
    assessment.patient= patient
    assessment.save!
    assessment
  end

  def answer question
    answers.where(:question => question).first
  end

  def answer= params
    #TODO validate answers
    params.each do |key, value |
    answer_var = answers.find_or_create_by(question_id: key)
    answer_var.update_attribute(:value, value)
    answers.create!
    #TODO save history ?
    end
  end

  def self.status_list
  [NOT_STARTED,STARTED_BUT_INCOMPLETE,COMPLETE]
  end

  def update_assessment params
  result = true
  if result
      result = update_attributes(params)
  end
  params[:answer].each do |a|
      answer=(a)
    end

  end
end
