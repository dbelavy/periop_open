class Professional
  include Mongoid::Document

  SURGEON = 'Surgeon'
  ANAESTHETIST = 'Anaesthetist'


  field :name, :type => String
  field :speciality, :type => String
  belongs_to :user

  has_many :surgeon_patients,:class_name => 'Patient',  inverse_of: :surgeon
  has_many :anaesthetist_patients,:class_name => 'Patient',  inverse_of: :anaesthetist

  def self.surgeons
    find(:all).where(:speciality => SURGEON)
  end

  def self.anaesthetists
      find(:all).where(:speciality => ANAESTHETIST)
  end

end
