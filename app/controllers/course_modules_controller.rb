class CourseModulesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['tutor','admin', 'content_manager'])
  end
  before_action :get_variables, except: :show

  def index
    qualification = Qualification.where(name_url: params[:qualification_url].to_s).first || ExamLevel.all_in_order.first.try(:qualification)
    exam_level = qualification.try(:exam_levels).try(:first)
    if exam_level
      redirect_to course_module_special_link(exam_level)
    else
      flash[:error] = I18n.t('controllers.course_modules.index.no_exam_level')
      redirect_to exam_levels_url
    end
  end

  def show
    if params[:qualification_url]
      @qualification = Qualification.with_url(params[:qualification_url]).first
      if @qualification
        if current_user.admin? || current_user.content_manager?
          @exam_levels = @qualification.exam_levels.all_in_order
          @exam_level = @exam_levels.where(name_url: params[:exam_level_url]).first || @exam_levels.first
          @exam_level_id = @exam_level.try(:id)
          if params[:course_module_url]
            @course_module = @exam_level.course_modules.with_url(params[:course_module_url]).first
          else
            @course_module = @exam_level.course_modules.all_in_order.first
          end
        else
          assigned_levels = ExamLevel.all_in_order.where(tutor_id: current_user.id)
          non_assigned_levels = ExamLevel.all_in_order.where(tutor_id: nil)
          exam_levels = assigned_levels + non_assigned_levels
          @exam_levels = exam_levels.uniq
          @exam_level = @exam_levels.first
          @exam_level_id = @exam_level.try(:id)
          if params[:course_module_url]
            @course_module = @exam_level.course_modules.with_url(params[:course_module_url]).first
          else
            @course_module = @exam_level.course_modules.all_in_order.first
          end
        end
      else
        flash[:error] = I18n.t('controllers.course_modules.show.cant_find')
        redirect_to course_modules_url
      end
    else
      flash[:error] =   I18n.t('controllers.course_modules.show.cant_find')
      redirect_to course_modules_url
    end
  end

  def new
    if params[:exam_section_url]
      exam_section = ExamSection.with_url(params[:exam_section_url]).first
      @course_module = CourseModule.new(sorting_order: 1,
          exam_section_id: exam_section.id,
          exam_level_id: exam_section.exam_level_id,
          qualification_id: exam_section.exam_level.qualification_id,
          institution_id: exam_section.exam_level.qualification.institution_id )
    elsif params[:exam_level_url]
      exam_level = ExamLevel.where(name_url: params[:exam_level_url]).first
      @course_module = CourseModule.new(sorting_order: 1,
          exam_level_id: exam_level.id,
          qualification_id: exam_level.qualification_id,
          institution_id: exam_level.qualification.institution_id )
    else
      @course_module = CourseModule.new(sorting_order: 1)
    end
    set_up_side_nav
  end

  def edit
    set_up_side_nav
  end

  def create
    @course_module = CourseModule.new(allowed_params)
    if @course_module.save
      flash[:success] = I18n.t('controllers.course_modules.create.flash.success')
      redirect_to course_module_special_link(@course_module)
    else
      set_up_side_nav
      render action: :new
    end
  end

  def update
    if @course_module.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_modules.update.flash.success')
      redirect_to course_module_special_link(@course_module)
    else
      set_up_side_nav
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseModule.find(the_id.to_i).update_attributes!(sorting_order: (counter + 1))
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
    if current_user.admin? || current_user.content_manager?
      @exam_levels = ExamLevel.all_in_order
    elsif current_user.tutor?
      assigned_levels = ExamLevel.all_in_order.where(tutor_id: current_user.id)
      non_assigned_levels = ExamLevel.all_in_order.where(tutor_id: nil)
      exam_levels = assigned_levels + non_assigned_levels
      @exam_levels = exam_levels.uniq
    end
    @exam_sections = ExamSection.all_in_order
    @tutors = User.all_tutors.all_in_order
  end

  def allowed_params
    params.require(:course_module).permit(:institution_id, :qualification_id, :exam_level_id, :exam_section_id, :name, :name_url, :description, :tutor_id, :sorting_order, :estimated_time_in_seconds, :active, :seo_description, :seo_no_index)
  end

  def set_up_side_nav
    @qualification = @course_module.exam_level.try(:qualification)
    @exam_level_id = @course_module.exam_level_id
  end

end
