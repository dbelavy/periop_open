class SummariesController < ApplicationController
  load_and_authorize_resource :patient


  def populate_summary
    @summary = {}
    @categories = Category.sorted
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
      }
    }
  end

  def populate_printable_summary
    populate_summary
    answer_array = []
    @categories.each do |category|
      if !@summary[category._id].nil? && @summary[category._id].size > 0
        concept_hash = @summary[category._id]
        puts " concept_hash.size " + concept_hash.size.to_s
        concept_hash[:row_number] =  concept_hash.size / 3 + ((concept_hash.size % 3 > 0 ) ? 1 : 0)
        concept_arr =[]
        category.concepts.sorted.each do |concept|
          if !concept_hash[concept._id].nil?
            concept_arr << concept_hash[concept._id]
          end
        end
        concept_hash[:array] = concept_arr
      end
    end
  end



  def show
     populate_summary
  end

  def show_printable
    populate_printable_summary
    render :show_printable,:layout => 'printer'
  end

  def summary_row assessment,answer
    return { answer: answer.value_to_s,
             details: answer.details,
             author: assessment.updated_by,
             date: assessment.date_str,
             assessment_name: assessment.name,
             concept_display_name: answer.question.concept.display_name
    }
  end
end