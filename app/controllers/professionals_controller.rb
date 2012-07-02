class ProfessionalsController < ApplicationController
  load_and_authorize_resource

  def show
    #@professional = Professional.find(params[:id])
  end

  def index
    @professionals = @professionals.paginate(:page => params[:page])
  end

  def reset_password
    #@professional = Professional.find(params[:id])
    @professional.user.send_reset_password_instructions
    redirect_to @professional, :notice => 'Password has been reset, instructions sent on user\'s email'
  end

  def new
    #@professional = Professional.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @professional }
    end
  end

  # POST /professionals
  # POST /professionals.json
  def create
    #@professional = Professional.new(params[:professional])
    logger.debug 'created professional ' + @professional.to_yaml

    respond_to do |format|
      if @professional.create_professional_dev
        format.html { redirect_to @professional, notice: 'Professional was successfully created.' }
        format.json { render json: @professional, status: :created, location: @professional }
      else
        format.html { render action: "new" }
        format.json { render json: @professional.errors, status: :unprocessable_entity }
      end
    end
  end
end
