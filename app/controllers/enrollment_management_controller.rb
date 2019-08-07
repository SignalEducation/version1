# frozen_string_literal: true

class EnrollmentManagementController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[user_management_access])
  end
  before_action :set_layout

  def index
    @enrollments = Enrollment.page(params[:page]).
                     search(params[:search]).
                     by_sitting(params[:exam_sitting]).
                     all_in_recent_order
  end

  def edit
    @enrollment = Enrollment.find(params[:id])
    @subject_course = @enrollment.subject_course
    standard_exam_sittings = ExamSitting.where(active: true, computer_based: false, subject_course_id: @subject_course.id, exam_body_id: @subject_course.exam_body_id).all_in_order
    computer_based_exam_sittings = ExamSitting.where(active: true, computer_based: true, exam_body_id: @subject_course.exam_body_id).all_in_order

    @exam_sittings = standard_exam_sittings + computer_based_exam_sittings
  end

  def update
    @enrollment = Enrollment.find(params[:id])

    if @enrollment.update_attributes(allowed_params)
      flash[:success] = t('controllers.enrollments.admin_update.flash.success')
    else
      flash[:error] = t('controllers.enrollments.admin_update.flash.error')
    end

    redirect_to user_activity_url(@enrollment.user)
  end

  def show
    @enrollment = Enrollment.find(params[:id])
  end

  def create_new_scul
    @enrollment = Enrollment.find(params[:id])
    @course = @enrollment.subject_course

    return if @enrollment.nil?

    scul = create_course_user_log(@course.id, @enrollment.user_id)

    if @enrollment.update_attribute(:subject_course_user_log_id, scul.id)
      flash[:success] = t('controllers.enrollments.admin_create_new_scul.flash.success')
    else
      flash[:error] = t('controllers.enrollments.admin_create_new_scul.flash.error')
    end

    redirect_to enrollment_management_url(@enrollment)
  end

  def export_log_data
    # TODO - Flagged for removal
    @enrollment = Enrollment.find(params[:id])
    @scul = @enrollment.subject_course_user_log
    @course_module_element_user_logs = @scul.course_module_element_user_logs

    respond_to do |format|
      format.html
      format.csv { send_data @course_module_element_user_logs.to_csv }
      format.xls { send_data @course_module_element_user_logs.to_csv(col_sep: "\t", headers: true), filename: "enrolment-#{@enrollment.id}-#{Date.today}.xls" }
    end
  end

  protected

  def set_layout
    @layout = 'management'
  end

  def allowed_params
    params.require(:enrollment).permit(:exam_date, :subject_course_user_log_id, :exam_sitting_id, :notifications, :expired, :active)
  end

  def create_course_user_log(course_id, user_id)
    SubjectCourseUserLog.create!(user_id: user_id, subject_course_id: course_id)
  end
end
