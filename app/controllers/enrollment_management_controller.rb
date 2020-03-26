# frozen_string_literal: true

class EnrollmentManagementController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[user_management_access]) }
  before_action :management_layout

  def index
    @enrollments = Enrollment.page(params[:page]).
                     search(params[:search]).
                     by_sitting(params[:exam_sitting]).
                     all_in_recent_order
  end

  def edit
    @enrollment = Enrollment.find(params[:id])
    @course = @enrollment.course
    standard_exam_sittings = ExamSitting.where(active: true, computer_based: false, course_id: @course.id, exam_body_id: @course.exam_body_id).all_in_order
    computer_based_exam_sittings = ExamSitting.where(active: true, computer_based: true, exam_body_id: @course.exam_body_id).all_in_order

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
    @course = @enrollment.course

    return if @enrollment.nil?

    scul = create_course_log(@course.id, @enrollment.user_id)

    if @enrollment.update_attribute(:course_log_id, scul.id)
      flash[:success] = t('controllers.enrollments.admin_create_new_scul.flash.success')
    else
      flash[:error] = t('controllers.enrollments.admin_create_new_scul.flash.error')
    end

    redirect_to enrollment_management_url(@enrollment)
  end

  def export_log_data
    # TODO - Flagged for removal
    @enrollment = Enrollment.find(params[:id])
    @scul = @enrollment.course_log
    @module_logs = @scul.module_logs

    respond_to do |format|
      format.html
      format.csv { send_data @module_logs.to_csv }
      format.xls { send_data @module_logs.to_csv(col_sep: "\t", headers: true), filename: "enrolment-#{@enrollment.id}-#{Date.today}.xls" }
    end
  end

  protected

  def allowed_params
    params.require(:enrollment).permit(:exam_date, :course_log_id, :exam_sitting_id, :notifications, :expired, :active)
  end

  def create_course_log(course_id, user_id)
    CourseLog.create!(user_id: user_id, course_id: course_id)
  end
end
