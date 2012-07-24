class Patient
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable,
  #    :registerable,:rememberable, :trackable, :validatable,:authentication_keys => [:ssn]
  #:recoverable,


  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  field :email, :type => String
  #field :name, :type => String
  #field :ssn, :type => String
  #field :dob, :type => Date

  field :ready_to_surgery, :type => Boolean,:default => false
  field :planned_date_of_surgery, :type => Date

  field :surgeon, :type => String

  belongs_to :anaesthetist, :class_name=> 'Professional',:inverse_of => :anaesthetist_patients
  has_many :assessments


  def get_answer_value_by_concept name
    answer = self.new_patient_assessment.find_answer_by_concept_name name
  end


  def find_or_create_answer_by_concept_name name
    self.new_patient_assessment.find_or_create_answer_by_concept_name name
  end

  def surname
    self.get_answer_value_by_concept "patient_surname"
  end

  def firstname
    self.get_answer_value_by_concept "patient_first_name"
  end

  def middlename
    self.get_answer_value_by_concept "patient_middle_name"
  end

  def firstname= value
    self.set_answer_value_by_concept( "patient_first_name",value)
  end

  def surname= value
    self.set_answer_value_by_concept( "patient_surname",value)
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


  #field :ssn, :type => String
  #field :dob, :type => Date
  def ssn
    self.get_answer_value_by_concept "social_security_number"
  end

  def ssn= value
    set_answer_value_by_concept  "social_security_number",value
  end

  def dob
    self.get_answer_value_by_concept "patient_dob"
  end

  def dob= value
    set_answer_value_by_concept  "patient_dob",value
  end

  def assigned
    assessments.map{|a| a.name}
  end


  def assigned= new_types
    assigned_types = assigned
    puts 'create assessments' + new_types.to_s
    (new_types - assigned_types).each{|n|
      if !n.to_s.empty?
        form = Form.where(:name => n).first
        Assessment.create_for_patient(form,self)
      end
    }
  end

  def patient_assessment_assigned?
    !assigned.find_index(Form::PATIENT_ASSESSMENT).nil?
  end

  def new_patient_assessment
    assessments.each { |a|
      if a.name == Form::NEW_PATIENT
        return a
      end
    }
    Assessment.create_for_patient(Form.new_patient_form,self)
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
