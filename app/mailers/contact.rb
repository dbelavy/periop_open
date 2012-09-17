class Contact < ActionMailer::Base

  def contact_mail contact
    @contact = contact
    mail(contact.header)
  end
end
