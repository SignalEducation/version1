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
#

class EnrollmentsController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def create
    log = create_subject_course_user_log
    @enrollment = Enrollment.new(user_id: @user.id, subject_course_user_log_id: log.id, subject_course_id: @course.id, active: true)
    if @enrollment.save
      if @course.email_content
        content = @course.email_content
      else
        content = @course.short_description
      end
      MandrillWorker.perform_at(5.minute.from_now, @user.id, 'send_enrollment_welcome_email', @course.name, content, library_special_link(@course.name_url))

      redirect_to course_special_link(@course.first_active_cme)
    end
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
      MandrillWorker.perform_at(5.minute.from_now, @user.id, 'send_enrollment_welcome_email', @course.name, content, library_special_link(@course.name_url))

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

  def get_variables
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    @user = current_user
  end

end
