class CbesController < ApplicationController

  skip_before_action :verify_authenticity_token

  def new
    SubjectCourse.all.pluck(:id, :name)
  end

  def index

  end

  def get_subjects
    render json: SubjectCourse.all.to_json(only: [:id, :name])
  end

  def show
    render json: Cbe.last
  end

  def create
    Cbe.new (params)
  end

  def create_it

    puts "**** Create #{params[:cbe_name]}"
    puts "**** Subject #{params[:selected_subject]}"
    #Cbe.new (params)
  end

end
