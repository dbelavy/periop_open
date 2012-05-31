class ProfessionalsController < ApplicationController
  
  def show
    @professional = Professional.find(params[:id])
  end

  def index
    @professionals = Professional.paginate(:page => params[:page])
  end
end
