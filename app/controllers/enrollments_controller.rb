# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  before_action :logged_in_required
  before_action :set_user

  def create
    @enrollment = Enrollment.new(allowed_params)

    @enrollment.computer_based_exam = true if @enrollment.exam_date && @enrollment&.course&.computer_based
    @enrollment.user_id = current_user.id
    @enrollment.active = true

    if @enrollment.save
      SegmentService.new.track_course_enrolment_event(@enrollment, params[:course_log_id].present?) unless Rails.env.test?
      flash[:success] = "Thank you. You have successfully enrolled in #{@enrollment&.course&.name}"
    else
      flash[:error] = t('controllers.enrollments.create.flash.error')
      redirect_to library_special_link(@enrollment.course)
    end
  end

  def edit
    @enrollment = Enrollment.find(params[:id])
    @course = @enrollment.course
    @exam_body = @course.exam_body if @course

    @exam_sittings = ExamSitting.where(active: true, computer_based: false, course_id: @course.id,
                                       exam_body_id: @course.exam_body_id).all_in_order
  end

  def update
    @enrollment = Enrollment.find(params[:id])

    if @enrollment.update_attributes(allowed_params)
      flash[:success] = t('controllers.enrollments.update.flash.success')
    else
      flash[:error] = t('controllers.enrollments.update.flash.error')
    end

    redirect_to account_url(anchor: :enrollments)
  end

  def update_exam_body_user_details
    unless @user&.update_attributes(exam_body_user_allowed_params)
      session[:user_exam_body_errors] = @user.errors unless @user.errors.empty?
    end

    redirect_to request.referrer
  end

  protected

  def allowed_params
    params.require(:enrollment).permit(:course_id, :exam_date, :course_log_id,
                                       :exam_sitting_id, :percentage_complete, :exam_body_id, :notifications)
  end

  def exam_body_user_allowed_params
    params.require(:user).permit(
      :date_of_birth,
      exam_body_user_details_attributes: [:id,
                                          :exam_body_id,
                                          :student_number]
    )
  end

  def set_user
    @user = current_user
  end
end
