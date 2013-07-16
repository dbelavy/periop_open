module ApplicationHelper

  def setup_assessment assessment
    contains_dob = false
    assessment.form.questions.sorted.each do |q|

      if !q.nil?
        if !q.concept.nil? && q.concept.name == "patient_dob"
          contains_dob = true
        end
        if assessment.answer(q).nil?
          assessment.answers_attributes= [{:question => q}]
        end
      end
    end
    assessment[:contains_dob] = contains_dob
    puts 'contains_dob ' + contains_dob.to_s
    return assessment
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

  def anesthetists_option_list
    Professional.anesthetists
  end

  def get_anesthetist_name assessment
    anesthetist = assessment.get_anesthetist
    if !anesthetist.nil?
      anesthetist.name
    else
      ""
    end
  end
end

