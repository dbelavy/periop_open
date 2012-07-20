module AssessmentsHelper
  def answer_for(question_name,assessment)
    q = Question.where(:display_name => question_name).first

    if !q.nil? && !assessment.answers.nil? && assessment.answers.size >0
      assessment.answers.where(:question_id => q._id).first.value_to_s
    end
  end
end
