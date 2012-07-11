class Answer
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  belongs_to :question , inverse_of: nil
  field :value, type: String
  field :details, type: String
  field :dateValue, type: Date
  embedded_in :assessment

  def value_to_s
    if !value.nil?
      return value
    end
    if !dateValue.nil?
      return dateValue
    end
  end
end