class PatientsDatatable
  delegate :params, :h, :link_to, :number_to_currency,:current_user , to: :@view

  def initialize(view,ability)
    @view = view
    @ability= ability
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
  #%td #{patient.anesthetist.name if !patient.anesthetist.nil?}
  #%td #{patient.surgeon}
  #%td #{patient.planned_date_of_surgery}
  #%td no


  def data
    patients.map do |patient|
      [
        link_to(patient.surname,patient),
        h(patient.firstname),
        h(patient.dob),
        #h(patient.anesthetist_name),
        h(patient.anesthetist.nil? ? '' : patient.anesthetist.name),
        h(patient.surgeon),
        h(patient.planned_date_of_surgery),
        link_to('show summary',
                Rails.application.routes.url_helpers.show_printable_patient_summary_path(patient),
                :target => "_blank")
      ]
    end
  end

  def patients
    @patients ||= fetch_patients
  end

  def fetch_patients
    patients = Patient.accessible_by(@ability)
    #patients = Patient.send("#{sort_direction}","#{sort_column}")
    if params[:sSearch].present?
      search = params[:sSearch]
      #TODO extract regexp & make tests
      if /\d{4}-\d{2}-\d{2}/.match(search)
        patients = patients.where(dob: Date.parse(search))
      elsif /\d{4}/.match(search)
        start_of_year = Date.ordinal(search.to_i)
        end_of_year = Date.ordinal(search.to_i,-1)
        patients = patients.where(:dob.gte => start_of_year,:dob.lte => end_of_year)
      else
        regex = /#{Regexp.escape(params[:sSearch])}/i
        patients = patients.where({ "$or" => [{firstname: regex},{surname: regex},{surgeon: regex}]})
        # workaround for issue #133
        # TODO make ability filter works, probably updating to mongoid 3.0
        if current_user.professional?
          patients = patients.all_in(anesthetist_id: current_user.professional.has_access_to)
        end

      end
    end
    patients = patients.send("#{sort_direction}","#{sort_column}")
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
    columns = %w[surname firstname dob anesthetist_name surgeon planned_date_of_surgery ready_to_surgery]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
