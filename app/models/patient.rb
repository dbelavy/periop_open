class Patient
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable,
  #    :registerable,:rememberable, :trackable, :validatable,:authentication_keys => [:ssn]
  #:recoverable,


  ## Database authenticatable
  field :email, :type => String, :null => false
  field :encrypted_password, :type => String, :null => false, :default => ""

  ## Recoverable
  field :reset_password_token, :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count, :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at, :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip, :type => String

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

  field :name, :type => String
  field :ssn, :type => String
  field :dob, :type => Date
  field :ready_to_surgery, :type => Boolean,:default => false
  field :planned_date_of_surgery, :type => Date



  validates_presence_of :name, :ssn
  belongs_to :user

  field :surgeon, :type => String
  belongs_to :anaesthetist, :class_name=> 'Professional',:inverse_of => :anaesthetist_patients
  has_many :assessments

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


  def assessment_types
    assigned_types = assigned
      result = Hash.new
      Form.all.each do |f|
        result[f.name]= assigned_types.include? f.name
      end
    result
  end

end
