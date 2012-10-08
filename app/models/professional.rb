class Professional
  include Mongoid::Document

  SURGEON = 'Surgeon'
  ANESTHETIST = 'Anesthetist'


  field :name, :type => String
  field :speciality, :type => String
  belongs_to :user
  field :discontinued, :type => Boolean, :default => false

  #has_many :surgeon_patients,:class_name => 'Patient',  inverse_of: :surgeon
  has_many :anesthetist_patients,:class_name => 'Patient',  inverse_of: :anesthetist

  def self.surgeons
    find(:all).where(:speciality => SURGEON)
  end

  def self.anesthetists
      find(:all).where(:speciality => ANESTHETIST).excludes(discontinued: true)
  end



  def self.specialities
    [SURGEON,ANESTHETIST ]
  end

  def label
    name
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
