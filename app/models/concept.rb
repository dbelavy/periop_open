  class Concept
  include Mongoid::Document

  cache

  field :name, :type => String
  field :display_name, :type => String
  field :order_in_category, :type => Integer
  field :position, :type => Integer

  field :conflict_resolution, :type => String

  ALL = "All"
  RECENT ="Recent"
  PROFESSIONAL = "Professional"
  PATIENT = "Patient"

  field :mpog_code, :type => String
  field :mpog_name, :type => String
  field :snomed_code, :type => String

  belongs_to :category
  has_many :questions

  def self.find_by_name namestr
    self.where(name: namestr).first
  end


  def self.sorted
    self.asc(:order_in_category)
  end

end
