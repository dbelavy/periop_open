class AssessmentsDatatable
  delegate :params, :h, :link_to,:patient_assessment_path, :number_to_currency, to: :@view

  def initialize(view,ability,patient=nil)
    @view = view
    @ability= ability
    @patient = patient
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: assessments.total_entries,
      iTotalDisplayRecords: assessments.total_entries,
      aaData: data
    }
  end

private

  def data
    assessments.map do |a|
      [
      (a.find_answer_value_by_concept_name 'patient_surname'),
      (a.find_answer_value_by_concept_name 'patient_first_name'),
      (a.find_answer_value_by_concept_name 'patient_gender'),
      (a.find_answer_value_by_concept_name 'patient_dob'),
      (a.find_answer_value_by_concept_name 'planned_procedure_date'),
      (a.find_answer_value_by_concept_name 'referring_surgeon'),
      (a.find_answer_value_by_concept_name 'anesthetist'),
      (if !@patient.nil?
        (link_to 'Show', patient_assessment_path(@patient,a),:class=> "btn ")
      else
        (link_to 'Show', a,:class=> "btn")
      end),
      (link_to("Delete assessment", a,:class => "btn btn-danger",:confirm => 'Are you sure?', :method => :delete))
      ]
    end
  end

  def assessments
    @assessments ||= fetch_assessments
  end

  def fetch_assessments
    assessments = Assessment.unassigned.accessible_by(@ability,:unassigned)
    #assessments = assessments.unassigned
    if !@patient.nil? && (assessments.find_possible_matches_by_patient(@patient).count > 0)
      assessments = assessments.find_possible_matches_by_patient @patient
    else
      if params[:sSearch].present?
        regex = /#{params[:sSearch]}/i
        assessments = assessments.find_possible_matches [regex ]
      end
    end

    assessments.paginate(:page => page,:per_page => per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end