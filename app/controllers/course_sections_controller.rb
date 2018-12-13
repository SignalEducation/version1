class CourseSectionsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(content_management_access))
  end
  before_action :get_variables

  # Standard Actions #

  def new
    @subject_course = SubjectCourse.where(id: params[:id]).first
    if @subject_course && @subject_course.course_sections.count > 0
      @course_section = CourseSection.new(sorting_order: @subject_course.course_sections.all_in_order.last.sorting_order + 1, subject_course_id: @subject_course.id)
    elsif @subject_course
      @course_section = CourseSection.new(sorting_order: 1, subject_course_id: @subject_course.id)
    else
      redirect_to subject_course_url
    end
  end

  def create
    @course_section = CourseSection.new(allowed_params)
    if @course_section.save
      flash[:success] = I18n.t('controllers.course_sections.create.flash.success')
      redirect_to course_module_special_link(@course_section)
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @course_section.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_sections.update.flash.success')
      redirect_to course_module_special_link(@course_section)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseSection.find(the_id.to_i).update_attributes!(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @course_section.destroy
      flash[:success] = I18n.t('controllers.course_sections.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.course_sections.destroy.flash.error')
    end
    redirect_to course_module_special_link(@course_section)
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_section = CourseSection.where(id: params[:id]).first
    end
    @subject_courses = SubjectCourse.all_in_order
    @tutors = User.all_tutors.all_in_order
    @layout = 'management'
  end

  def allowed_params
    params.require(:course_section).permit(:name, :name_url, :sorting_order, :active, :subject_course_id,
                                          :counts_towards_completion, :assumed_knowledge)
  end

end
