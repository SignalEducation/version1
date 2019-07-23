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
   # render json: Cbe.first
  end

  def create
  end

  def create_section
    cbe_section = CbeSection.create(section_params)  
    res = {cbeSectionId: cbe_section.id, cbeSectionName: cbe_section.name}
    render json: (res.as_json)
  end

  def create_it
    cbe = Cbe.create(cbe_params)
    res = {cbeId: cbe.id, cbeName: cbe.name}
    render json: (res.as_json)
  end

  def question_types
    res = CbeQuestionType.all.to_json(only: [:id, :name])
    render json: (res)
  end

  def question_statuses
    res = CbeQuestionStatus.all.to_json(only: [:id, :name])
    render json: (res)
  end

  def section_types
    res = CbeSectionType.all.to_json(only: [:id, :name])
    render json: (res)
  end


  private

  def cbe_params
    params.require(:cbe).permit(:name, :title, :description, :subject_course_id, :time, :number_of_pauses, :length_of_pauses)
  end


  def section_params
    params.require(:cbe_section).permit(:name, :scenario_label, :scenario_description, :cbe_id)
  end

  protected

  def get_variables
    @layout = 'management'
  end


end
