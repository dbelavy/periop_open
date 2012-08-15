module ApplicationHelper

  def setup_assessment assesment
    assesment.form.questions.sorted.each do |q|
      if !q.nil?
        if assesment.answer(q).nil?
          assesment.answers_attributes= [{:question => q}]
        end
      end
    end
  return assesment
end

def patient_signed_in?
  # TODO remove occurrences
  false
end

end
