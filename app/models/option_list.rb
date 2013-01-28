class OptionList
  include Mongoid::Document

  cache

  field :name , :type => String
  field :order_number, :type => Integer
  field :label, :type => String
  field :value, :type => String
  field :snomed_code, :type => String
end
