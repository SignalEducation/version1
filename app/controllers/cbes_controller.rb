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

  def create_section
    cbe_section = CbeSection.create(name: 'Intro',
                                    scenario_label: 'S Label',
                                    scenario_description: 'S Desc',
                                    cbe_id: params[:cbe_id])

    res = {cbeId: cbe.id, cbeName: cbe.name}
    render json: (res.as_json)
  end

  def create_it
    cbe = Cbe.create(name: params[:cbe_name],
                     title: 'exam 1',
                     description: 'test desc',
                     subject_course_id: params[:selected_subject]
    )

    res = {cbeId: cbe.id, cbeName: cbe.name}
    render json: (res.as_json)
  end


end
