class PatientsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Patient.count,
      iTotalDisplayRecords: patients.total_entries,
      aaData: data
    }
  end

private

  #%td #{link_to patient.name, patient}
  #%td #{patient.dob}
  #%td #{patient.anaesthetist.name if !patient.anaesthetist.nil?}
  #%td #{patient.surgeon}
  #%td #{patient.planned_date_of_surgery}
  #%td no


  def data
    patients.map do |patient|
      [
        link_to(patient.surname,patient),
        h(patient.firstname),
        h(patient.dob),
        #h(patient.anaesthetist_name),
        h(patient.anaesthetist.nil? ? '' : patient.anaesthetist.name),
        h(patient.surgeon),
        h(patient.planned_date_of_surgery),
        h('no'),
        link_to('show summary', Rails.application.routes.url_helpers.patient_summary_path(patient)),
        link_to('show assessments',Rails.application.routes.url_helpers.patient_assessments_path(patient)),
        link_to('edit details', Rails.application.routes.url_helpers.edit_patient_path(patient))
      ]
    end
  end

  def patients
    @patients ||= fetch_patients
  end

  def fetch_patients
    patients = Patient.all.send("#{sort_direction}","#{sort_column}")
    if params[:sSearch].present?
      search = params[:sSearch]
      #TODO extract regexp & make tests
      if /\d{4}-\d{2}-\d{2}/.match(search)
        patients = patients.where(dob: Date.parse(search))
      elsif /\d{4}/.match(search)
        start_of_year = Date.ordinal(search.to_i)
        end_of_year = Date.ordinal(search.to_i,-1)
        patients = patients.where(:dob.gte => start_of_year,:dob.lte => end_of_year)
      elsif /^\D*$/.match(search)
        regex = /#{params[:sSearch]}/i
        patients = patients.any_of({firstname: regex},{surname: regex},{anaesthetist_name: regex},{surgeon: regex})
      end
    end
    patients = patients.paginate(:page => page,:per_page => per_page)
    patients
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[surname firstname dob anaesthetist_name surgeon planned_date_of_surgery ready_to_surgery]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end