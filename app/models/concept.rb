class Concept
  include Mongoid::Document
  field :name, :type => String
  field :display_name, :type => String
  field :snomed_code, :type => String
  field :mpog_code, :type => String
  field :position, :type => Integer

  has_many :questions



end
