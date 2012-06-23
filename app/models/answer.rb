class Answer
  include Mongoid::Document

  belongs_to :question , inverse_of: nil
  field :value, type: String
  field :dateValue, type: Date
  embedded_in :assessment

end