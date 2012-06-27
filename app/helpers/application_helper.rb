module ApplicationHelper

  def setup_assessment assesment
    assesment.form.questions.each do |q|
      if assesment.answer(q).nil?
        assesment.answers_attributes= [{:question => q}]
      end

    end
    assesment
  end

  def patient_signed_in?
    # TODO remove occurrences
    false
  end

end
