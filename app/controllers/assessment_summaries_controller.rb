class AssessmentSummariesController < BaseSummariesController
  load_and_authorize_resource :assessment


  def populate_summary
    logger.debug 'populate summary'
    @summary = {}
    @categories = Category.sorted
    process_assessment @assessment
  end

  def show
     populate_summary
    render 'summaries/show'
  end

  def show_printable
    populate_printable_summary
    render 'summaries/show_printable',:layout => 'printer'
  end


end