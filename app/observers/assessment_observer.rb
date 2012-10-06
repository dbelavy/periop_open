class AssessmentObserver < Mongoid::Observer

  def before_save(assessment)
    assessment[:anesthetist_id] = assessment.get_anesthetist_id
  end
end
