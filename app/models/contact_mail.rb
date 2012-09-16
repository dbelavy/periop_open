class ContactMail
  include Mongoid::Document

  field :name, type:String
  field :email, type:String
  field :contact_telephone, type:String
  field :message, type:String

  #validates :email, :email_format => true
  validates :message, :presence => true

  def send_message
    Contact.contact_mail(self).deliver
  end

  def header
    {:to => Rails.application.config.contact_mail_target,
     :subject => subject,
     :template_path => 'contact', :template_name => 'contact'
    }
  end

  def subject
    "User request from " + (name || '') + " " + (contact_telephone || '')
  end


end