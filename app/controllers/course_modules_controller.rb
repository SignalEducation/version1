class CourseModulesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['tutor','admin'])
  end
  before_action :get_variables, except: :show

  def index
    @qualifications = Qualification.paginate(per_page: 100, page: params[:page]).all_in_order
  end

  def show
    if params[:qualification_url]
      @qualification = Qualification.with_url(params[:qualification_url]).first
      if @qualification
        @exam_level_id = @qualification.exam_levels.first.try(:id)
        if params[:course_module_url]
          @course_module = CourseModule.with_url(params[:course_module_url]).first
        end
      else
        flash[:error] = I18n.t('controllers.course_modules.show.cant_find')
        redirect_to course_modules_url
      end
    else
      flash[:error] = I18n.t('controllers.course_modules.show.cant_find')
      redirect_to course_modules_url
    end
  end

  def new
    if params[:exam_level_id]
      exam_level = ExamLevel.find(params[:exam_level_id])
      @course_module = CourseModule.new(sorting_order: 1,
          exam_level_id: exam_level.id,
          qualification_id: exam_level.qualification_id,
          institution_id: exam_level.qualification.institution_id )
    else
      @course_module = CourseModule.new(sorting_order: 1)
    end
  end

  def edit
  end

  def create
    @course_module = CourseModule.new(allowed_params)
    if @course_module.save
      flash[:success] = I18n.t('controllers.course_modules.create.flash.success')
      redirect_to course_modules_url
    else
      render action: :new
    end
  end

  def update
    if @course_module.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_modules.update.flash.success')
      redirect_to course_modules_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseModule.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @course_module.destroy
      flash[:success] = I18n.t('controllers.course_modules.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.course_modules.destroy.flash.error')
    end
    redirect_to course_modules_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_module = CourseModule.where(id: params[:id]).first
    end
    @institutions = Institution.all_in_order
    @qualifications = Qualification.all_in_order
    @exam_levels = ExamLevel.all_in_order
    @exam_sections = ExamSection.all_in_order
    @tutors = User.includes(:user_group).references(:user_groups).where('user_groups.tutor = ?', true).all_in_order
  end

  def allowed_params
    params.require(:course_module).permit(:institution_id, :exam_level_id, :exam_section_id, :name, :name_url, :description, :tutor_id, :sorting_order, :estimated_time_in_seconds, :compulsory, :active)
  end

end
