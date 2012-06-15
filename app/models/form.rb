class Form
  include Mongoid::Document
  field :name, :type => String
  field :person_role, :type => Array
  has_and_belongs_to_many :questions, inverse_of: nil

end