class Concept
  include Mongoid::Document
  field :name, :type => String
  field :display_name, :type => String
  field :order_in_category, :type => Integer
  field :position, :type => Integer

  field :mpog_code, :type => String
  field :mpog_name, :type => String
  field :snomed_code, :type => String

  belongs_to :category
  has_many :questions

  def self.find_by_name name
    self.where(name: name).first
  end

end
