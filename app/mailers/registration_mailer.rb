class RegistrationMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  def define_password_instructions(record)
    devise_mail(record, :define_password_instructions)
  end



end