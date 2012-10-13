class SummariesController < ApplicationController
  load_and_authorize_resource :patient


  def populate_summary
    logger.debug 'populate summary'
    @summary = {}
    @categories = Category.sorted
    @patient.assessments.each{|assessment|
      if !assessment.completed?
        next
      end
      #puts 'assessment ' + assessment.to_s
      assessment.answers.each {|ans|
        if ans.value_to_s.blank?
          next
        end
        #puts 'answer ' + ans.value_to_s
        concept = ans.question.concept
        concept_id = concept._id
        category =  ans.question.concept.category
        logger.debug 'concept :' + concept.name
        logger.debug 'category :' + category.summary_display
        logger.debug 'answer : ' + ans.value_to_s.to_s
        if @summary[category._id].nil?
          @summary[category._id] = {}
        end

        concepts_hash = @summary[category._id]
        if concepts_hash[concept_id].nil?
          concepts_hash[concept_id] = Array.new
        end
        concepts_array = concepts_hash[concept_id]
        # resolving conflicts
        if concept.conflict_resolution == Concept::RECENT
          if concepts_array.size == 0 ||
            (concepts_array.size > 0 && assessment.date_started.to_time > (concepts_array[0][:datetime].to_time))
            concepts_array[0] = summary_row(assessment,ans)
          end
        elsif concept.conflict_resolution == Concept::PROFESSIONAL
          if assessment.updated_by != "Patient"
            concepts_array << summary_row(assessment,ans)
          end
        elsif concept.conflict_resolution == Concept::PATIENT
          if assessment.updated_by == "Patient"
            concepts_array << summary_row(assessment,ans)
          end
        else
          #consider "ALL" as default strategy
          concepts_array << summary_row(assessment,ans)
        end
        logger.debug 'concepts_array : ' + concepts_array.to_s
      }
    }
  end


  def populate_printable_summary
    populate_summary
    answer_array = []
    @categories.each do |category|
      if !@summary[category._id].nil? && @summary[category._id].size > 0
        concepts_hash = @summary[category._id]
        concepts_hash[:row_number] =  concepts_hash.size / 3 + ((concepts_hash.size % 3 > 0 ) ? 1 : 0)
        concepts_hash[:array] = get_concepts_sorted(category, concepts_hash)
      end
    end
  end


  def get_concepts_sorted(category, concepts_hash)
    concept_arr =[]
    category.concepts.sorted.each do |concept|
      if !concepts_hash[concept._id].nil?
        concept_arr << concepts_hash[concept._id]
      end
    end
    logger.warn 'concept_arr category: ' + category.to_s + ' ' + concept_arr.to_s
    concept_arr
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
             datetime: assessment.date_started,
             assessment_name: assessment.name,
             concept_display_name: answer.question.concept.display_name
    }
  end
end