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
    puts "Is this the new id ? -- #{cbe.id}"
    res = {:cbeId => cbe.id}
    render json: (res.as_json)
  end

end
