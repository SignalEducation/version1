class CourseModulesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['tutor','admin', 'content_manager'])
  end
  before_action :get_variables

  def show
    redirect_to subject_course_url
  end

  def new
    @subject_course = SubjectCourse.where(name_url: params[:subject_course_name_url]).first
    if @subject_course
      @course_module = CourseModule.new(sorting_order: 1, subject_course_id: @subject_course.id, tutor_id: @subject_course.tutor_id)
    else
      @course_module = CourseModule.new(sorting_order: 1, subject_course_id: SubjectCourse.all_active.all_in_order.last.id, tutor_id: @subject_course.tutor_id)
    end
  end

  def edit
  end

  def create
    @course_module = CourseModule.new(allowed_params)
    if @course_module.save
      flash[:success] = I18n.t('controllers.course_modules.create.flash.success')
      redirect_to course_module_special_link(@course_module)
    else
      render action: :new
    end
  end

  def update
    if @course_module.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_modules.update.flash.success')
      redirect_to course_module_special_link(@course_module)
    else
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
    redirect_to course_module_special_link(@course_module)
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_module = CourseModule.where(id: params[:id]).first
    end
    @subject_courses = SubjectCourse.all_in_order
    @tutors = User.all_tutors.all_in_order
  end

  def allowed_params
    params.require(:course_module).permit(:name, :name_url, :description, :tutor_id, :sorting_order, :estimated_time_in_seconds, :active, :seo_description, :seo_no_index, :number_of_questions, :subject_course_id)
  end

end
