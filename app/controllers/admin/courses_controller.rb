# frozen_string_literal: true

module Admin
  class CoursesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :get_variables

    def index
      @courses =
        if params[:group_id]
          Course.where(group_id: params[:group_id]).all_in_order
        else
          Course.all_in_order
        end

      @courses =
        if params[:search].to_s.blank?
          @courses.all_in_order
        else
          @courses.search(params[:search])
        end
    end

    def show; end

    def new
      @course = Course.new(sorting_order: 1)
    end

    def create
      @course = Course.new(allowed_params)

      if @course.save
        flash[:success] = I18n.t('controllers.courses.create.flash.success')
        redirect_to courses_url
      else
        render action: :new
      end
    end

    def edit; end

    def update
      if @course.update_attributes(allowed_params)
        flash[:success] = I18n.t('controllers.courses.update.flash.success')
        redirect_to courses_url
      else
        render action: :edit
      end
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |id, counter|
        Course.find_by(id: id).update_attributes(sorting_order: (counter + 1))
      end

      render json: {}, status: :ok
    end

    def destroy
      if @course.destroy
        flash[:success] = I18n.t('controllers.courses.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.courses.destroy.flash.error')
      end

      redirect_to courses_url
    end

    def clone
      if @course.duplicate
        flash[:success] = 'Course successfully duplicaded'
      else
        flash[:error] = 'Course not successfully duplicaded'
      end

      redirect_to courses_url
    end

    # Non-standard Actions #
    ## Index, New & Create Actions for CourseResources that belong_to this Course ##
    def course_resources
      @course = Course.find(params[:id])
      @course_resources = @course.course_resources.all_in_order
    end

    def new_course_resources
      @course = Course.find(params[:id])
      @course_resource = CourseResource.new(course_id: @course.id)
    end

    def create_course_resources
      @course = Course.find(params[:id])
      @course_resource = CourseResource.new(resource_allowed_params)
      @course_resource.course_id = @course.id
      if @course_resource.save
        flash[:success] = I18n.t('controllers.course_resources.create.flash.success')
        redirect_to course_url(@course)
      else
        render action: :new_course_resources
      end
    end

    ## Misc Actions ##
    ### Creates list of the Course's CourseModules for Drag&Drop reordering (posted to CourseModules#reorder) ###
    def lessons_order
      @lessons = @course.children
    end

    ### Triggered by a Update Student Logs Button ###
    def update_student_exam_tracks
      course = Course.where(id: params[:id]).first
      course.update_all_course_logs

      redirect_to course_url(course)
    end

    def trial_content; end

    def update_trial_content
      if @course.update_attributes(nested_trial_params)
        flash[:success] = I18n.t('controllers.courses.update.flash.success')
        redirect_to course_url(@course)
      else
        render action: :trial_content
      end
    end

    def export_course_logs
      @course = Course.find(params[:id])
      @sculs = @course.course_logs

      respond_to do |format|
        format.html
        format.csv { send_data @sculs.to_csv() }
        format.xls { send_data @sculs.to_csv(col_sep: "\t", headers: true), filename: "#{@course.name}-user-logs-#{Date.today}.xls" }
      end
    end

    protected

    def get_variables
      @course = Course.find_by(id: params[:id]) if params[:id].to_i > 0
      @groups = Group.all_in_order
      @levels = Level.all
      @tutors = User.all_tutors.all_in_order
      @exam_bodies = ExamBody.all_in_order
    end

    def allowed_params
      params.require(:course).permit(
        :name, :name_url, :sorting_order, :active, :description, :release_date,
        :short_description, :exam_body_id, :default_number_of_possible_exam_answers,
        :background_image, :survey_url, :quiz_pass_rate, :group_id, :preview,
        :computer_based, :highlight_colour, :category_label, :icon_label,
        :seo_title, :seo_description, :has_correction_packs, :short_description,
        :on_welcome_page, :unit_label, :level_id,
        course_sections_attributes: [
          lessons_attributes: [
            course_module_elements_attributes: [
              :available_on_trial
            ]
          ]
        ]
      )
    end

    def nested_trial_params
      params.require(:course).permit(
        course_resources_attributes: [:id, :available_on_trial],
        course_sections_attributes: [
          :id,
          lessons_attributes: [
            :id,
            course_module_elements_attributes: [:id, :available_on_trial]
          ]
        ]
      )

    end

    def resource_allowed_params
      params.require(:course_resource).permit(:name, :course_id,
                                                      :description, :file_upload,
                                                      :external_url, :active,
                                                      :available_on_trial)
    end
  end
end
