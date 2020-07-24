# frozen_string_literal: true

module Admin
  class CourseLessonsController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :get_variables

    def show; end

    def new
      @course_sections = @course.course_sections.all_in_order
      if @course && @course_section && @course_section.course_lessons.count > 0
        @course_lesson = CourseLesson.new(sorting_order: @course_section.course_lessons.all_in_order.last.sorting_order + 1,
                                          course_id: @course.id,
                                          course_section_id: @course_section.id)
      elsif @course
        @course_lesson = CourseLesson.new(sorting_order: 1, course_id: @course.id,
                                          course_section_id: @course_section.id)
      else
        redirect_to root_url
      end
    end

    def create
      @course_lesson = CourseLesson.new(allowed_params)

      if @course_lesson.free && @course_lesson.save
        flash[:success] = 'Free Lesson Successfully Created'
        redirect_to admin_course_free_lesson_content_path(@course_lesson.course)
      elsif @course_lesson.save
        flash[:success] = I18n.t('controllers.course_lessons.create.flash.success')
        redirect_to admin_course_url(@course_lesson.course_id)
      else
        render action: :new
      end
    end

    def edit
      @course_sections = @course.course_sections.all_in_order
    end

    def update
      @course_lesson = CourseLesson.where(id: params[:id]).first

      if @course_lesson.update_attributes(allowed_params)
        flash[:success] = I18n.t('controllers.course_lessons.update.flash.success')
        redirect_to admin_course_url(@course_lesson.course_id)
      else
        flash[:error] = @course_lesson.errors.full_messages.to_sentence
        redirect_to admin_edit_course_lesson_url(@course_lesson.course_id, @course_lesson.course_section.id, @course_lesson.id)
      end
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |the_id, counter|
        CourseLesson.find(the_id.to_i).update_attributes!(sorting_order: (counter + 1))
      end
      render json: {}, status: :ok
    end

    def destroy
      @course_lesson = CourseLesson.find(params[:id])

      if @course_lesson.destroy
        flash[:success] = I18n.t('controllers.course_lessons.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.course_lessons.destroy.flash.error')
      end
      redirect_to admin_course_url(@course_lesson.course_id)
    end

    protected

    def get_variables
      @course         = Course.where(id: params[:id]).first if params[:id].to_i > 0
      @course_section = CourseSection.where(id: params[:course_section_id]).first if params[:course_section_id].to_i > 0
      @course_lesson  = CourseLesson.where(id: params[:course_lesson_id]).first if params[:id].to_i > 0
      @courses        = Course.all_in_order
      @tutors         = User.all_tutors.all_in_order
    end

    def allowed_params
      params.require(:course_lesson).permit(:name, :name_url, :description, :sorting_order,
                                            :estimated_time_in_seconds, :active, :seo_description,
                                            :seo_no_index, :number_of_questions, :course_id,
                                            :highlight_colour, :tuition, :test, :revision, :course_section_id,
                                            :temporary_label, :free)
    end
  end
end
