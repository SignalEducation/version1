class CbesController < ApplicationController

  skip_before_action :verify_authenticity_token

  def new
    render json: SubjectCourse.all.pluck(:id, :name)
  end

  def index

  end

  def show
    render json: Cbe.last
  end

  def create
    Cbe.new (params)
  end

  def create_it

    puts "**** Create #{params[:cbeName]}"
    #Cbe.new (params)
  end

end
