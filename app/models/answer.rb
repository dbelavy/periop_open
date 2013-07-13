class Answer
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  belongs_to :question , inverse_of: nil
  field :value, type: String
  field :id_value, type: String
  field :array_value, type: Array
  field :details, type: String
  field :date_value, type: Date
  embedded_in :assessment

  validates_date :date_value, :allow_nil => true,:allow_blank => true
  validate :require_questions_answered

  def value_to_s
    if !value.blank?
      return value
    end
    if !array_value.nil?
      return array_value * ","
    end
    if !date_value.nil?
      return date_value
    end
    if !id_value.nil? && !id_value.blank?
      return Professional.find(id_value).label
    end
    ""
  end


  def require_questions_answered
    if self.question.nil?
      # TODO delete this answers
      puts 'answer without question' + self.inspect
    else
      if self.question.required.eql?('Y')&& self.value_to_s.blank?
        #errors.add(:base, 'Answer required')
        errors.add(:value, 'can\'t be blank')
      end
    end
  end

  def update_answer value
    input_type = self.question.input_type
    if input_type == "Date"
      self.update_attribute(:date_value, value)
    elsif input_type == "ManyOptions"
      self.update_attribute(:array_value, value)
    elsif input_type == "Lookup_User_Anesthetist"
      self.update_attribute(:id_value, value)
    else
      self.update_attribute(:value, value)
    end
  end

  def sorted

  end
end