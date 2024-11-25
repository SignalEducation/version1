# frozen_string_literal: true

module Admin
  class CourseSectionsController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :get_variables

    def new
      @course = Course.where(id: params[:id]).first

      if @course && @course.course_sections.count > 0
        @course_section = CourseSection.new(sorting_order: ((@course.course_sections.any? && @course.course_sections.all_in_order.last.sorting_order) ? @course.course_sections.all_in_order.last.sorting_order + 1 : 1), course_id: @course.id)
      elsif @course
        @course_section = CourseSection.new(sorting_order: 1, course_id: @course.id)
      else
        redirect_to admin_courses_url
      end
    end

    def create
      @course_section = CourseSection.new(allowed_params)

      if @course_section.save
        flash[:success] = I18n.t('controllers.course_sections.create.flash.success')
        redirect_to admin_course_url(@course_section.course)
      else
        render action: :new
      end
    end

    def edit; end

    def update
      if @course_section.update_attributes(allowed_params)
        flash[:success] = I18n.t('controllers.course_sections.update.flash.success')
        redirect_to admin_course_url(@course_section.course)
      else
        render action: :edit
      end
    end

    def reorder_list
      @course = Course.where(id: params[:course_id]).first
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |the_id, counter|
        CourseSection.find(the_id.to_i).update_attributes!(sorting_order: (counter + 1))
      end

      render json: {}, status: :ok
    end

    def destroy
      if @course_section.destroy
        flash[:success] = I18n.t('controllers.course_sections.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.course_sections.destroy.flash.error')
      end

      redirect_to admin_course_url(@course_section.course)
    end

    protected

    def get_variables
      @courses        = Course.all_in_order
      @tutors         = User.all_tutors.all_in_order
      @course_section = CourseSection.where(id: params[:id]).first if params[:id].to_i > 0
    end

    def allowed_params
      params.require(:course_section).permit(:name, :name_url, :sorting_order, :active, :course_id,
                                             :counts_towards_completion, :assumed_knowledge)
    end
  end
end
