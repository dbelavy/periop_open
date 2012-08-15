module ApplicationHelper

  def setup_assessment assesment
    categories = Category.sorted
    categories.each do |category|
      category.concepts.sorted.each do |concept|
        # TODO assuming one concept per form
        q = assesment.form.questions.where(:concept_id => concept._id).first
        if !q.nil?
          puts " q " +  q.to_s
          #puts " setup for concept " +  concept.to_s
          if assesment.answer(q).nil?
            assesment.answers_attributes= [{:question => q}]
          end
        end
      end
    end

    #assesment.form.questions.each do |q|
    #  if assesment.answer(q).nil?
    #    assesment.answers_attributes= [{:question => q}]
    #  end
    #
    #end
    return assesment
  end

  def patient_signed_in?
    # TODO remove occurrences
    false
  end

end
