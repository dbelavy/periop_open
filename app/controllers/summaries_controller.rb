class SummariesController < ApplicationController
  load_and_authorize_resource :patient

  def show
    @summary = {}
    @categories = Category.all
    @patient.assessments.each{|assessment|
      #puts 'assessment ' + assessment.to_s
      assessment.answers.each {|ans|
        #puts 'answer ' + ans.value_to_s
        concept_id = ans.question.concept._id
        if @summary[concept_id].nil?
          @summary[concept_id] = Array.new
        end
          @summary[concept_id] << summary_row(assessment,ans)
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