class Contact < ActionMailer::Base
  default from: "from@example.com"

  def contact_mail contact
    @contact = contact
    mail(contact.header)
  end
end
