class Category
  include Mongoid::Document
  field :level_1_name, :type => String
  field :level_1_order, :type => Integer
  field :level_2_name, :type => String
  field :level_2_order, :type => Integer
  field :summary_display, :type => String

  has_many :concepts
end