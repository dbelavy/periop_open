class AssessmentMailer < ActionMailer::Base
  default from: Rails.application.config.mail_sender

  def patient_assessment_mail(anesthetist)
    if anesthetist.nil?
      return false
    end
    @professional = anesthetist
    mail(:to => anesthetist.user.email,
         :from => Rails.application.config.mail_sender,
         :subject => "New Patient Assessment")

  end
end
