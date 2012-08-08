class SummariesController < ApplicationController
  load_and_authorize_resource :patient

  def show
    @summary = {}
    @categories = Category.all
    @patient.assessments.each{|assessment|
      #puts 'assessment ' + assessment.to_s
      assessment.answers.each {|ans|
        if ans.value_to_s.blank?
          next
        end
        #puts 'answer ' + ans.value_to_s
        concept_id = ans.question.concept._id
        category =  ans.question.concept.category
        if @summary[category._id].nil?
          @summary[category._id] = {}
        end
        concept_hash = @summary[category._id]
        if concept_hash[concept_id].nil?
          concept_hash[concept_id] = Array.new
        end
          concept_hash[concept_id] << summary_row(assessment,ans)
        logger.debug @summary.as_json
      }
    }
  end

  def summary_row assessment,answer
    return { answer: answer.value_to_s,
             details: answer.details,
             author: assessment.updated_by,
             date: assessment.date_str,
             assessment_name: assessment.name
    }
  end
end