class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email, :type => String, :null => false, :default => ""
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
  field :confirmation_token, :type => String
  field :confirmed_at, :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email, :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  # run 'rake db:mongoid:create_indexes' to create indexes
  index :email, :unique => true

  field :user_role, :type => String, :default => 'undefined'

  # user related to role specific entity
  has_one :professional

  validates_presence_of :email
  attr_accessible :email, :password, :password_confirmation, :remember_me, :confirmed_at

  attr_protected :user_role

  PROFESSIONAL = 'professional'
  ADMIN = 'admin'


  def admin?
    self.user_role==ADMIN

  end

  def professional?
    self.user_role == PROFESSIONAL
  end

  def patient?
    self.user_role =='patient'
  end

  def name
    if ((!user_role.nil?) && (user_role!= 'undefined'))
        if (user_role!= 'admin')
        related = self.send(user_role)
        related.name.to_s
        else
          "admin"
        end
    end
  end



  def assign_role( role_name)
    if self.user_role != 'undefined'
      raise 'Role already assigned'
    end
    self[:user_role] =  role_name
    save!
    if role_name == ADMIN

    elsif role_name == PROFESSIONAL
      self.create_professional();
    else
      raise 'Unknown role! ' + role_name
    end
  end

  def to_s
    result = 'User : ' + email
    result
  end
end