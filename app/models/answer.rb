class Answer
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  belongs_to :question , inverse_of: nil
  field :value, type: String
  field :details, type: String
  field :date_value, type: Date
  embedded_in :assessment

  def value_to_s
    if !value.nil?
      return value
    end
    if !date_value.nil?
      return date_value
    end
  end

  def update_answer value
    input_type = self.question.input_type
    if input_type == "Date"
      self.update_attribute(:date_value, value)
    else
      self.update_attribute(:value, value)
    end
  end
end