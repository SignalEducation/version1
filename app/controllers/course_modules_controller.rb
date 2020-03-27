# frozen_string_literal: true

class CourseModulesController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[content_management_access]) }
  before_action :management_layout
  before_action :get_variables

  def show; end

  def new
    @course_sections = @course.course_sections.all_in_order
    if @course && @course_section && @course_section.lessons.count > 0
      @course_module = CourseModule.new(sorting_order: @course_section.lessons.all_in_order.last.sorting_order + 1,
                                        course_id: @course.id,
                                        course_section_id: @course_section.id)
    elsif @course
      @course_module = CourseModule.new(sorting_order: 1, course_id: @course.id,
                                        course_section_id: @course_section.id)
    else
      redirect_to root_url
    end
  end

  def create
    @course_module = CourseModule.new(allowed_params)

    if @course_module.save
      flash[:success] = I18n.t('controllers.lessons.create.flash.success')
      redirect_to course_url(@course_module.course_id)
    else
      render action: :new
    end
  end

  def edit
    @course_sections = @course.course_sections.all_in_order
  end

  def update
    @course_module = CourseModule.where(id: params[:id]).first

    if @course_module.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.lessons.update.flash.success')
      redirect_to course_url(@course_module.course_id)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseModule.find(the_id.to_i).update_attributes!(sorting_order: (counter + 1))
    end
    render json: {}, status: :ok
  end

  def destroy
    @course_module = CourseModule.find(params[:id])

    if @course_module.destroy
      flash[:success] = I18n.t('controllers.lessons.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.lessons.destroy.flash.error')
    end
    redirect_to course_module_special_link(@course_module)
  end

  protected

  def get_variables
    @course = Course.where(id: params[:id]).first if params[:id].to_i > 0
    @course_section = CourseSection.where(id: params[:course_section_id]).first if params[:course_section_id].to_i > 0
    @course_module = CourseModule.where(id: params[:course_module_id]).first if params[:course_module_id].to_i > 0
    @courses = Course.all_in_order
    @tutors = User.all_tutors.all_in_order
  end

  def allowed_params
    params.require(:course_module).permit(:name, :name_url, :description, :sorting_order,
                                          :estimated_time_in_seconds, :active, :seo_description,
                                          :seo_no_index, :number_of_questions, :course_id,
                                          :highlight_colour, :tuition, :test, :revision, :course_section_id,
                                          :temporary_label)
  end
end
