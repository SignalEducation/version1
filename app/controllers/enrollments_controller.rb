# == Schema Information
#
# Table name: enrollments
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subject_course_id          :integer
#  subject_course_user_log_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  active                     :boolean          default(FALSE)
#  exam_body_id               :integer
#  exam_date                  :date
#  expired                    :boolean          default(FALSE)
#  paused                     :boolean          default(FALSE)
#  notifications              :boolean          default(TRUE)
#  exam_sitting_id            :integer
#  computer_based_exam        :boolean          default(FALSE)
#  percentage_complete        :integer          default(0)
#

class EnrollmentsController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def create

    @enrollment = Enrollment.new(allowed_params)

    @enrollment.computer_based_exam = true if @enrollment.exam_date && @enrollment&.subject_course&.computer_based
    @enrollment.user_id = current_user.id
    @enrollment.active = true

    if @enrollment.save
      #redirect_to library_special_link(@enrollment.subject_course)
      flash[:success] = "Thank you. You have successfully enrolled in #{@enrollment&.subject_course&.name}"
    else
      flash[:error] = t('controllers.enrollments.create.flash.error')
      redirect_to library_special_link(@enrollment.subject_course)
    end
  end

  def edit
    @enrollment = Enrollment.find(params[:id])
    @subject_course = @enrollment.subject_course
    @exam_body = @subject_course.exam_body if @subject_course

    @exam_sittings = ExamSitting.where(active: true, computer_based: false, subject_course_id: @subject_course.id,
                                       exam_body_id: @subject_course.exam_body_id).all_in_order


  end

  def update
    @enrollment = Enrollment.find(params[:id])

    if @enrollment.update_attributes(allowed_params)
      flash[:success] = t('controllers.enrollments.update.flash.success')
      redirect_to account_url(anchor: :enrollments)
    else
      flash[:error] = t('controllers.enrollments.update.flash.error')
      redirect_to account_url(anchor: :enrollments)
    end

  end

  def update_exam_body_user_details
    if @user && @user.update_attributes(exam_body_user_allowed_params)
      redirect_to request.referrer
    else
      session[:user_exam_body_errors] = @user.errors unless @user.errors.empty?
      redirect_to request.referrer
    end
  end

  protected

  def send_welcome_email(user_id, course_name)
    #Turned Off until emails are all moved back from intercom
    MandrillWorker.perform_at(5.minute.from_now, user_id, 'send_enrollment_welcome_email', course_name, account_url)
  end

  def allowed_params
    params.require(:enrollment).permit(:subject_course_id, :exam_date, :subject_course_user_log_id,
                                       :exam_sitting_id, :percentage_complete, :exam_body_id, :notifications)
  end

  def exam_body_user_allowed_params
    params.require(:user).permit(:date_of_birth, exam_body_user_details_attributes: [
        :id,
        :exam_body_id,
        :student_number])
  end

  def get_variables
    @user = current_user
  end

end
