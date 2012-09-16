class ContactMailsController < ApplicationController

  def new
    @contact = ContactMail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contact}
    end
  end

  # POST /forms
  # POST /forms.json
  def create
    @contact = ContactMail.new(params[:contact_mail])
    @contact.send_message
    respond_to do |format|
      if @contact.save
        format.html { redirect_to root_path, notice: 'Your question has been sent, we will be in touch shortly' }
        format.json { render json: @form, status: :created, location: @form }
      else
        format.html { render action: "new" }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

end