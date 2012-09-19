class Assessment
  include Mongoid::Document

  NOT_STARTED = 'not started'
  STARTED_BUT_INCOMPLETE = 'Started but incomplete'
  COMPLETE = 'Complete'


  field :status, :type => String, :default => NOT_STARTED
  field :date_started, :type => DateTime
  field :updated_by, :type => String
  field :name, :type => String

  belongs_to :patient
  belongs_to :form

  embeds_many :answers
  accepts_nested_attributes_for :answers

  validate :answers_empty

   def answers_empty
     if answers.all?{|answer| answer.value_to_s.blank? }
       errors.add(:base, 'All answers can\'t be blank')
     end
   end

  def self.create_for_patient(form, patient)
    assessment = self.new
    assessment.form= form
    assessment.name = form.name
    assessment.patient= patient
    assessment
  end

  def answer question
    answers.where(:question_id => question._id).first
  end

  def answers_unique?
    result = true
    self.form.questions.each do |q|
      question_answers = self.answers.where(:question_id => q._id)
      if question_answers.size > 1
        message = '!!! Patient\'s '  + self.patient.surname + self.patient._id.to_s +  ' assessment  ' + self.to_s + ' is invalid ' + ' question ' +
            q.to_s + ' have more than one answers:' + question_answers.all.map{|a| a.value_to_s }.to_s
        logger.error message
        puts message
        result = false
      end
    end
    result
  end


  def find_or_create_answer question
    answers.find_or_create_by(:question_id => question._id)
  end

  def self.status_list
    [NOT_STARTED, STARTED_BUT_INCOMPLETE, COMPLETE]
  end

  def update_assessment params, current_user
    result = true
    professional_name = current_user.professional.name.to_s
    self.updated_by= professional_name
    if result
      result = update_attributes(params)
    end
    self.patient.update_values
    result
  end

  def find_or_create_answer_by_concept_name concept_name
    self.find_or_create_answer(find_question_by_concept_name (concept_name))
  end

  def find_answer_by_concept_name concept_name
    question = find_question_by_concept_name concept_name
    if !question
      return nil
    end
    answer = self.answer(question)
  end


  def find_answer_value_by_concept_name concept
    answer = find_answer_by_concept_name concept
    if answer.nil?
      return ""
    end
    answer.value_to_s
  end


  def find_question_by_concept_name concept_name
    concept = Concept.find_by_name(concept_name)
    self.form.questions.where(concept_id: concept._id).first
  end

  def start_and_complete_assessment
    self.date_started = Time.now
    self.status= COMPLETE
    self.updated_by = 'Patient'
  end

  def completed?
    !self.date_started.nil? && self.status == COMPLETE
  end

  def name
    form.name if !form.nil?
  end

  def date_str
    self.date_started.nil? ? " " : self.date_started.strftime(" %m/%d/%Y")
  end

  def summary
    self.name + date_str + ' status: ' + self.status
  end
end