class AssessmentObserver < Mongoid::Observer

  def before_save(assessment)
    assessment[:anesthetist_id] = assessment.get_anesthetist_id
  end

  def after_save(assessment)
    assessment.patient.update_values
  end

  def before_create(assessment)
      assessment.date_started = Time.now
  end
end
