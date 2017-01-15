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
#  student_number             :string
#  exam_body_id               :integer
#  exam_date                  :date
#  registered                 :boolean          default(FALSE)
#

class EnrollmentsController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def create
    log = create_subject_course_user_log
    if params[:registered] && !params[:not_registered]
      @enrollment = Enrollment.new(allowed_params)
      @enrollment.registered = true
      dob = params[:date_of_birth] if params[:date_of_birth] && params[:date_of_birth].present?
      if params[:custom_exam_date].present? && !params[:exam_date].present?
        date = params[:custom_exam_date]
      elsif !params[:custom_exam_date].present? && params[:exam_date].present?
        date = params[:exam_date]
      end
      @enrollment.exam_date = date
    elsif !params[:registered] && params[:not_registered]
      @enrollment = Enrollment.new(limited_params)
    end
    @enrollment.user_id = @user.id
    @enrollment.subject_course_user_log_id = log.id
    @enrollment.subject_course_id = @course.id
    @enrollment.exam_body_id = @exam_body.id
    @enrollment.active = true

    if @enrollment.save
      @user.update_attribute(:date_of_birth, dob) if params[:date_of_birth]
      send_welcome_email
      redirect_to course_special_link(@course.first_active_cme)
    else
      flash[:error] = 'The data entered for the enrolment was not valid. Please try again!'
      redirect_to library_special_link(@course)
    end
  end

  def send_welcome_email
    if @course.email_content
      content = @course.email_content
    else
      content = @course.short_description
    end
    course_parent_url = @course.subject_course_category == SubjectCourseCategory.default_subscription_category ? 'subscription_course' : 'product_course'
    url = Rails.application.routes.default_url_options[:host] + "/#{course_parent_url}/#{@course.name_url}"
    MandrillWorker.perform_at(5.minute.from_now, @user.id, 'send_enrollment_welcome_email', @course.name, content, url)
  end

  def create_with_order
    log = create_subject_course_user_log
    @enrollment = Enrollment.new(user_id: @user.id, subject_course_user_log_id: log.id, subject_course_id: @course.id, active: true)
    if @enrollment.save
      if @course.email_content
        content = @course.email_content
      else
        content = @course.short_description
      end
      course_parent_url = @course.subject_course_category == SubjectCourseCategory.default_subscription_category ? 'subscription_course' : 'product_course'
      unless Rails.env.test?
        url = Rails.application.routes.default_url_options[:host] + "/#{course_parent_url}/#{@course.name_url}"
        MandrillWorker.perform_at(5.minute.from_now, @user.id, 'send_enrollment_welcome_email', @course.name, content, url)
      end
      redirect_to diploma_course_url(@course.name_url)
    end
  end

  def pause
    @enrollment = Enrollment.find(params[:enrollment_id])
    @enrollment.update_attributes(active: false)
    redirect_to "#{account_url}#enrollment"
  end

  def activate
    @enrollment = Enrollment.find(params[:enrollment_id])
    @enrollment.update_attributes(active: true)
    redirect_to account_url(anchor: :enrollments)
  end


  protected

  def create_subject_course_user_log
    log = @user.subject_course_user_logs.where(subject_course_id: @course.id).first
    if log
      log
    else
      SubjectCourseUserLog.create!(user_id: @user.id, session_guid: current_session_guid, subject_course_id: @course.id)
    end
  end

  def allowed_params
    params.require(:enrollment).permit(:subject_course_id, :student_number, :exam_date, :registered)
  end

  def limited_params
    params.require(:enrollment).permit(:registered)
  end

  def get_variables
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    @exam_body = @course.exam_body if @course.exam_body_id
    @user = current_user
  end

end
