class Professional
  include Mongoid::Document

  SURGEON = 'Surgeon'
  ANAESTHETIST = 'Anaesthetist'


  field :name, :type => String
  field :speciality, :type => String
  belongs_to :user

  #has_many :surgeon_patients,:class_name => 'Patient',  inverse_of: :surgeon
  has_many :anaesthetist_patients,:class_name => 'Patient',  inverse_of: :anaesthetist

  def self.surgeons
    find(:all).where(:speciality => SURGEON)
  end

  def self.anaesthetists
      find(:all).where(:speciality => ANAESTHETIST)
  end



  def self.specialities
    [SURGEON,ANAESTHETIST ]
  end

  #def user_attributes=(attributes)
  #  @credit_card = CreditCard.new(attributes)
  #end


  def create_professional
    user = self.user
    user.user_role = User::PROFESSIONAL
    generated_password = Devise.friendly_token.first(6)
    user.password= generated_password
    success = user.save
    if (success)
      user.generate_reset_password_token!
      success = self.save
      RegistrationMailer.define_password_instructions(user).deliver
    end
    success
  end

end
