# This class is specific to patient assessments only
class AssessmentsDatatable
  delegate :params, :h, :link_to,:patient_assessment_path,:assessment_summary_path,
           :show_printable_assessment_summary_path, :number_to_currency,:patient_assessment_assign_path, to: :@view

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
      (a.find_answer_value_by_concept_name 'patient_dob'),
      (a.date_started.to_date.to_formatted_s(:db)),
      (a.find_answer_value_by_concept_name 'procedure_date_patient_reported'),
      (a.find_answer_value_by_concept_name 'referring_surgeon'),
      (if !@patient.nil?
        (link_to('<i class="icon-list" ></i>'.html_safe, patient_assessment_path(@patient,a),:class=> "btn ",:title => "Questionnaire"))
      else
        (link_to '<i class="icon-list" ></i>'.html_safe, a,:class=> "btn btn-small",:title => "Questionnaire")
      end),
      link_to('<i class="icon-folder-open" ></i>'.html_safe,assessment_summary_path(a),:class=> "btn btn-small",:title => "Assessment"),
      link_to('<i class="icon-print" ></i>'.html_safe,show_printable_assessment_summary_path(a),:class=> "btn btn-small",:title => "Printable"),
      (if !@patient.nil? && a.patient.nil?
          link_to('<i class="icon-plus" ></i>'.html_safe,patient_assessment_assign_path(@patient,a), :method => :put,
                  :class=> "btn btn-small",:title => "Join")
      end),
      (link_to("<i class=\'icon-remove\'></i>".html_safe, a,:class => "btn btn-small btn-danger",:confirm => 'Are you sure?', :method => :delete,:title => "Delete"))
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
        regex = /#{Regexp.escape(params[:sSearch])}/i
        assessments = assessments.find_possible_matches [regex ]
      end
    end

    assessments = assessments.send("desc","date_started")
    assessments.paginate(:page => page,:per_page => per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[surname	firstname	dob	form_date	surgery_date anesthetist]
    columns[params[:iSortCol_0].to_i||"form_date"]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
