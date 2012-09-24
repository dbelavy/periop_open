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


  def printed_answer concept_composite
    puts "concept_composite " + concept_composite.to_s
    concept_composite.map {|sum|
      result = ""
    if !sum[:answer].to_s.blank?
       result += sum[:answer].to_s
     end
    if !sum[:details].to_s.blank?
       result +=   " (" + sum[:details] +' )'
    end
      result
    }.uniq.join(" | ")
  end

  def professional_option_list
    Professional.all
  end

  def get_anesthetist_name assessment
    id = assessment.find_answer_value_by_concept_name 'patient_reported_anesthetist'
    puts 'get_anesthetist_name  ' +  id.to_s
    if ((!id.nil?)&&(!id.blank?))
      Professional.find(id.to_s).name
    end
  end
end
