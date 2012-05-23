class Patient
  include Mongoid::Document

  field :ssn, :type => String
  field :birth_day, :type => Date

  belongs_to :user

end
