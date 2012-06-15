module ApplicationHelper

  def setup_assessment assesment
    assesment.form.questions.each do |q|
      if assesment.answer(q).nil?
        assesment.answers_attributes= [{:question => q}]
      end

    end
    assesment
  end

end
