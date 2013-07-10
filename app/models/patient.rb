class Patient
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  field :email, :type => String
  field :firstname, :type => String
  field :middlename, :type => String
  field :surname, :type => String
  field :medicare_card_number, :type => String
  field :medicare_card_number_identifier, :type => String
  field :individual_healthcare_identifier, :type => String
  field :anesthetist_name, :type => String


  field :ssn, :type => String
  field :dob, :type => Date

  field :ready_to_surgery, :type => Boolean,:default => false
  field :planned_date_of_surgery, :type => Date

  field :surgeon, :type => String

  belongs_to :anesthetist, :class_name=> 'Professional',:inverse_of => :anesthetist_patients
  has_many :assessments

  accepts_nested_attributes_for :assessments



  def get_answer_value_from_patient_form concept_name
    answer = self.new_patient_assessment.find_answer_value_by_concept_name concept_name
    puts 'get_answer_value_from_patient_form  ' + concept_name + ' value: ' + answer.to_s
    answer
  end

  def get_answer_from_patient_form concept_name
      self.new_patient_assessment.find_answer_by_concept_name concept_name
  end


  def find_or_create_answer_by_concept_name name
    self.new_patient_assessment.find_or_create_answer_by_concept_name name
  end

  def set_answer_value_by_concept(concept_name, value)
    answer = self.find_or_create_answer_by_concept_name concept_name
    answer.update_answer value
  end

  def assessments_to_display
    result = []
    assessments.each{|a|
      if a.name != Form::NEW_PATIENT
        result << a
      end
    }
    result
  end

  def update_values
    # denormalized values for sorting

    self.firstname =  self.get_answer_value_from_patient_form "patient_first_name"
    self.middlename =  self.get_answer_value_from_patient_form "patient_middle_name"
    self.surname= self.get_answer_value_from_patient_form"patient_surname"
    self.ssn= self.get_answer_value_from_patient_form "social_security_number"
    self.dob= self.get_answer_value_from_patient_form "patient_dob"
    self.medicare_card_number= self.get_answer_value_from_patient_form "medicare_card_number"
    self.medicare_card_number_identifier= self.get_answer_value_from_patient_form "medicare_card_number_identifier"
    self.individual_healthcare_identifier= self.get_answer_value_from_patient_form "individual_healthcare_identifier"

    anesthetist_answer = self.get_answer_from_patient_form("anesthetist")
    if !anesthetist_answer.nil?
      self.anesthetist_id = anesthetist_answer.id_value
    end
    self[:anesthetist_name]= self.anesthetist.nil? ? '' : self.anesthetist.name

    # update from recent assessment
    surgeon_answer = self.get_recent_answer("referring_surgeon")
    if surgeon_answer
      self.surgeon = surgeon_answer.value_to_s
    end

    date_answer = self.get_recent_answer("planned_procedure_date")
    if date_answer
      self.planned_date_of_surgery = date_answer.date_value
    end

    self.save
  end

  def get_recent_answer concept
    puts ' get_recent_answer ' + concept.to_s
    recent_answer = nil
    self.assessments.each do |a|
      answer =  a.find_answer_by_concept_name concept
      if answer && !answer.value_to_s.blank?
        if recent_answer.nil? ||(recent_answer.assessment.date_started.to_time < answer.assessment.date_started.to_time)
          recent_answer = answer
        end
      end
    end
    recent_answer
    #puts 'recent ' + recent_answer.value_to_s
  end

  def assigned
    assessments.map{|a| a.name}
  end


  def assigned= new_types
    assigned_types = assigned
    (new_types - assigned_types).each{|n|
      if !n.to_s.empty?
        form = Form.where(:name => n).first
        Assessment.create_for_patient(form,self)
      end
    }
  end

  def patient_assessment_assigned?
    false
  end

  def new_patient_assessment
    assessments.each do |a|
      if a.name == Form::NEW_PATIENT
        return a
      end
    end
    assessment = Assessment.create_for_patient(Form.new_patient_form,self)
    assessment.start_and_complete_assessment
    assessment
  end

  def assessment_types
    assigned_types = assigned
      result = Hash.new
      Form.all.each do |f|
        result[f.name]= assigned_types.include? f.name
      end
    result
  end
end
