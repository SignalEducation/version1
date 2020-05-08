# frozen_string_literal: true

module Admin
  class CourseTutorsController < ApplicationController
    before_action :logged_in_required
    before_action do
      ensure_user_has_access_rights(%w[system_requirements_access content_management_access user_management_access])
    end
    before_action :management_layout
    before_action :get_variables

    def index
      @course_tutors = @course.course_tutors.all_in_order
    end

    def new
      @course_tutor = CourseTutor.new(course_id: @course.id, sorting_order: 1)
    end

    def edit; end

    def create
      @course_tutor = CourseTutor.new(allowed_params)

      if @course_tutor.save
        flash[:success] = I18n.t('controllers.course_tutors.create.flash.success')
        redirect_to admin_course_course_tutors_url(@course)
      else
        render action: :new
      end
    end

    def update
      if @course_tutor.update_attributes(allowed_params)
        flash[:success] = I18n.t('controllers.course_tutors.update.flash.success')
        redirect_to admin_course_course_tutors_url(@course)
      else
        render action: :edit
      end
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |the_id, counter|
        CourseTutor.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
      end

      render json: {}, status: :ok
    end

    def destroy
      if @course_tutor.destroy
        flash[:success] = I18n.t('controllers.course_tutors.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.course_tutors.destroy.flash.error')
      end

      redirect_to admin_course_course_tutors_url(@course)
    end

    protected

    def get_variables
      @course_tutor = CourseTutor.where(id: params[:id]).first if params[:id].to_i > 0
      @course      = Course.where(id: params[:course_id]).first if params[:course_id].to_i > 0
      @tutor_users         = User.all_tutors.all_in_order
    end

    def allowed_params
      params.require(:course_tutor).permit(:course_id, :user_id, :sorting_order, :title)
    end
  end
end
