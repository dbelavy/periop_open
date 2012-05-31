class Professional
  include Mongoid::Document
  field :name, :type => String

  belongs_to :user
end
