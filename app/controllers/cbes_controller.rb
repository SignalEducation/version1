class CbesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(system_requirements_access))
  end
  before_action :get_variables

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
    cbe = Cbe.create(cbe_params)
    res = {cbeId: cbe.id, cbeName: cbe.name}
    render json: (res.as_json)
  end


  private

  def cbe_params
    params.require(:cbe).permit(:name, :title, :description, :subject_course_id, :time, :number_of_pauses, :length_of_pauses)
  end

  protected

  def get_variables
    @layout = 'management'
  end


end
