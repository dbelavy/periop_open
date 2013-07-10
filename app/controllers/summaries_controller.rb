class SummariesController < BaseSummariesController
  load_and_authorize_resource :patient


  def populate_summary
    logger.debug 'populate summary'
    @summary = {}
    @categories = Category.sorted
    @patient.assessments.each do |assessment|
     process_assessment assessment
    end
  end

  def show
     populate_summary
  end

  def show_printable
    populate_printable_summary
    render :show_printable,:layout => 'printer'
  end


end