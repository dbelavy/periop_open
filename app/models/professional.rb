class Professional
  include Mongoid::Document

  SURGEON = 'Surgeon'
  ANESTHETIST = 'Anesthetist'
  ADMINISTRATIVE_STAFF = 'Administrative staff'



  field :name, :type => String
  field :speciality, :type => String
  belongs_to :user
  field :discontinued, :type => Boolean, :default => false
  field :shared_professionals_ids, :type => Array

  def shared_professionals_ids
    if self[:shared_professionals_ids].nil?
      return []
    else
      return self[:shared_professionals_ids].select{|id| !id.blank?}.map{|id| BSON::ObjectId(id)}
    end
  end

  #has_many :surgeon_patients,:class_name => 'Patient',  inverse_of: :surgeon
  has_many :anesthetist_patients,:class_name => 'Patient',  inverse_of: :anesthetist

  def slug
    name.tr(" ","-")
  end

  def self.find_by_slug slug
    find(:all).where(:name => slug.tr("-"," "))
  end

  def self.surgeons
    find(:all).where(:speciality => SURGEON)
  end

  def self.anesthetists
      find(:all).where(:speciality => ANESTHETIST).excludes(discontinued: true)
  end

  def self.anesthetists_without_self id
    find(:all).where(:speciality => ANESTHETIST).excludes(discontinued: true).excludes(:id => id)
  end

  def self.specialities
    [SURGEON,ANESTHETIST,ADMINISTRATIVE_STAFF ]
  end

  def label
    name
  end

  #def user_attributes=(attributes)
  #  @credit_card = CreditCard.new(attributes)
  #end

  def has_access_to
    result = []
    if self.speciality == ANESTHETIST
      result << self._id
    end
    result.concat shared_professionals_ids
    result
  end

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
