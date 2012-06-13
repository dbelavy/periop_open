class Answer
  include Mongoid::Document

  belongs_to :question , inverse_of: nil
  field :value, type: String
  embedded_in :assessment

end