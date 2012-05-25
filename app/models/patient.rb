class Patient
  include Mongoid::Document

  field :name,:type => String
  field :ssn, :type => String
  field :birth_day, :type => Date

  belongs_to :user

end
