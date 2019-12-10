# frozen_string_literal: true

class SubjectCoursesController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[content_management_access]) }
  before_action :management_layout
  before_action :get_variables

  def index
    @subject_courses =
      if params[:group_id]
        SubjectCourse.where(group_id: params[:group_id]).all_in_order
      else
        SubjectCourse.all_in_order
      end

    @subject_courses =
      if params[:search].to_s.blank?
        @subject_courses.all_in_order
      else
        @subject_courses.search(params[:search])
      end
  end

  def show; end

  def new
    @subject_course = SubjectCourse.new(sorting_order: 1)
  end

  def create
    @subject_course = SubjectCourse.new(allowed_params)

    if @subject_course.save
      flash[:success] = I18n.t('controllers.subject_courses.create.flash.success')
      redirect_to subject_courses_url
    else
      render action: :new
    end
  end

  def edit; end

  def update
    if @subject_course.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.subject_courses.update.flash.success')
      redirect_to subject_courses_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |id, counter|
      SubjectCourse.find_by(id: id).update_attributes(sorting_order: (counter + 1))
    end

    render json: {}, status: :ok
  end

  def destroy
    if @subject_course.destroy
      flash[:success] = I18n.t('controllers.subject_courses.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.subject_courses.destroy.flash.error')
    end

    redirect_to subject_courses_url
  end

  # Non-standard Actions #
  ## Index, New & Create Actions for SubjectCourseResources that belong_to this SubjectCourse ##
  def subject_course_resources
    @subject_course = SubjectCourse.find(params[:id])
    @subject_course_resources = @subject_course.subject_course_resources.all_in_order
  end

  def new_subject_course_resources
    @subject_course = SubjectCourse.find(params[:id])
    @subject_course_resource = SubjectCourseResource.new(subject_course_id: @subject_course.id)
  end

  def create_subject_course_resources
    @subject_course = SubjectCourse.find(params[:id])
    @subject_course_resource = SubjectCourseResource.new(resource_allowed_params)
    @subject_course_resource.subject_course_id = @subject_course.id
    if @subject_course_resource.save
      flash[:success] = I18n.t('controllers.subject_course_resources.create.flash.success')
      redirect_to subject_course_url(@subject_course)
    else
      render action: :new_subject_course_resources
    end
  end

  ## Misc Actions ##
  ### Creates list of the Course's CourseModules for Drag&Drop reordering (posted to CourseModules#reorder) ###
  def course_modules_order
    @course_modules = @subject_course.children
  end

  ### Triggered by a Update Student Logs Button ###
  def update_student_exam_tracks
    subject_course = SubjectCourse.where(id: params[:id]).first
    subject_course.update_all_course_logs

    redirect_to subject_course_url(subject_course)
  end

  def trial_content; end

  def update_trial_content
    if @subject_course.update_attributes(nested_trial_params)
      flash[:success] = I18n.t('controllers.subject_courses.update.flash.success')
      redirect_to subject_course_url(@subject_course)
    else
      render action: :trial_content
    end
  end

  def export_course_user_logs
    @course = SubjectCourse.find(params[:id])
    @sculs = @course.subject_course_user_logs

    respond_to do |format|
      format.html
      format.csv { send_data @sculs.to_csv() }
      format.xls { send_data @sculs.to_csv(col_sep: "\t", headers: true), filename: "#{@course.name}-user-logs-#{Date.today}.xls" }
    end
  end

  protected

  def get_variables
    @subject_course = SubjectCourse.find_by(id: params[:id]) if params[:id].to_i > 0
    @groups = Group.all_in_order
    @levels = Level.all
    @tutors = User.all_tutors.all_in_order
    @exam_bodies = ExamBody.all_in_order
  end

  def allowed_params
    params.require(:subject_course).permit(
      :name, :name_url, :sorting_order, :active, :description, :release_date,
      :short_description, :exam_body_id, :default_number_of_possible_exam_answers,
      :background_image, :survey_url, :quiz_pass_rate, :group_id, :preview,
      :computer_based, :highlight_colour, :category_label, :icon_label,
      :seo_title, :seo_description, :has_correction_packs, :short_description,
      :on_welcome_page, :unit_label, :level_id,
      course_sections_attributes: [
        course_modules_attributes: [
          course_module_elements_attributes: [
            :available_on_trial
          ]
        ]
      ]
    )
  end

  def nested_trial_params
    params.require(:subject_course).permit(
      subject_course_resources_attributes: [:id, :available_on_trial],
      course_sections_attributes: [
        :id,
        course_modules_attributes: [
          :id,
          course_module_elements_attributes: [:id, :available_on_trial]
        ]
      ]
    )

  end

  def resource_allowed_params
    params.require(:subject_course_resource).permit(:name, :subject_course_id,
                                                    :description, :file_upload,
                                                    :external_url, :active,
                                                    :available_on_trial)
  end
end
