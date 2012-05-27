class Patient
  include Mongoid::Document

  field :name,:type => String
  field :ssn, :type => String
  field :birth_day, :type => Date

  validates_presence_of :name,:ssn
  belongs_to :user

end
