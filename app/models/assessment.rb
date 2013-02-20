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

  embeds_many :answers
  accepts_nested_attributes_for :answers
  field :anesthetist_id, :type => String

  validate :answers_empty

 def answers_empty
   if answers.all?{|answer| answer.value_to_s.blank? }
     errors.add(:base, 'All answers can\'t be blank')
   end
 end

  def self.create_for_patient(form, patient)
    assessment = self.new
    assessment.name = form.name
    assessment.patient= patient
    assessment
  end

  def answer question
    answers.where(:question_id => question._id).first
  end

  def self.unassigned
    where(patient_id: nil)
  end

  def answers_exist_in_form?
    questions_array = self.form.questions.map {|q| q._id}
    result = true
    self.answers.each  do |a|
      if a.question_id.nil?
        result = false
        message = '!!! assessment : ' + self._id.to_s + ' has answer that does not have question id ' +  a._id.to_s
        logger.error message
        puts message
      elsif !questions_array.include? a.question_id
        message = '!!! assessment : ' + self._id.to_s + ' has answer : ' + a._id.to_s + ' to question: ' + a.question_id.to_s + '  that not exist in form '
        logger.error message
        puts message
        result = false
      end
    end
    result
  end

  def answers_unique?
    result = true
    self.form.questions.each do |q|
      question_answers = self.answers.where(:question_id => q._id)
      if question_answers.size > 1
        message = '!!!  assessment  ' + self._id.to_s + ' is invalid ' + ' question ' +
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
    set_update_by(current_user)
    self.date_started = Time.now
    if result
      result = update_attributes(params)
    end
    #TODO remove?
    self.patient.update_values
    result
  end

  def set_update_by(current_user)
    professional_name = current_user.professional.name.to_s
    self.updated_by= professional_name
  end

  def find_or_create_answer_by_concept_name concept_name
    self.find_or_create_answer(find_question_by_concept_name (concept_name))
  end

  def find_answer_by_concept_name concept_name
    question = find_question_by_concept_name concept_name
    if !question
      return nil
    end
    self.answer(question)
  end


  def find_answer_value_by_concept_name concept
    answer = find_answer_by_concept_name concept
    if answer.nil?
      return ""
    end
    result = answer.value_to_s
    #puts 'find_answer_value_by_concept_name ' + concept + ' value: ' + result.to_s
    result
  end


  def find_question_by_concept_name concept_name
    concept = Concept.find_by_name(concept_name)
    self.form.questions.by_concept(concept)
  end

  def start_and_complete_assessment
    self.date_started = Time.now
    self.status= COMPLETE
    self.updated_by = 'Patient'
  end

  def completed?
    !self.date_started.nil? && self.status == COMPLETE
  end

  def date_str
    self.date_started.nil? ? " " : self.date_started.to_date.to_s
  end

  def summary
    self.name + " " +  date_str + ' status: ' + self.status
  end

  def get_anesthetist_id
      answer  = self.find_answer_by_concept_name 'anesthetist'
      if (!answer.nil?)&&(!answer[:id_value].nil?)&&(!answer[:id_value].blank?)
        answer[:id_value]
      end
    end

  def get_anesthetist
    id = get_anesthetist_id
    if (!id.nil?)
      Professional.find(id)
    end
  end

  #
  #concept = Concept.find_by_name(concept_name)
  #self.form.questions.where(concept_id: concept._id).first


  def self.find_possible_matches_by_patient patient
    self.find_possible_matches [patient.firstname, patient.surname]
  end

  def self.find_possible_matches array
    #also_in({"answers.value" => array})
    where({"answers.value" => {"$in" => array}})
  end

  def self.patient_assessment_question_by_concept_name concept_name
    concept = Concept.find_by_name(concept_name)
    Form.patient_form.questions.by_concept(concept)
  end

  def form
    if self.name
      return Form.find_by_name(self.name)
    else
      return Form.find(self.form_id)
    end
  end

  def form= form
    self.name= form.name
  end
end