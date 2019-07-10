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
    cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', subject_course_id: 1)
  end

  def create_it

    puts "**** Create #{params[:cbe_name]}"
    puts "**** Subject #{params[:selected_subject]}"
    cbe = Cbe.create(name: params[:cbe_name],
                     title: 'exam 1',
                     description: 'test desc',
                     subject_course_id: params[:selected_subject]
    )
    #Cbe.new (params)
    #
    Cbe.new()
  end

end
