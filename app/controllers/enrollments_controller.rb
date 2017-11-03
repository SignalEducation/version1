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
#

class EnrollmentsController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def create
    @course = SubjectCourse.find(params[:enrollment][:subject_course_id])
    @exam_body = @course.exam_body

    @enrollment = Enrollment.new(allowed_params)
    if params[:custom_exam_date].present? && !params[:exam_date].present?
      date = params[:custom_exam_date]
    elsif !params[:custom_exam_date].present? && params[:exam_date].present?
      date = params[:exam_date]
    end
    @enrollment.exam_date = date
    @enrollment.user_id = current_user.id
    @enrollment.exam_body_id = @exam_body.id
    @enrollment.active = true

    #If scul_id is not sent in as param then make a new one, or if this is first enrollment find old one
    @enrollment.subject_course_user_log_id = find_or_create_scul(@course.id) unless @enrollment.subject_course_user_log_id


    if @enrollment.save
      send_welcome_email(current_user.id, @course.name)
      redirect_to library_special_link(@course)
      flash[:success] = 'Thank you for your Enrolment Details'
    else
      flash[:error] = 'The data entered for the enrolment was not valid. Please try again!'
      redirect_to library_special_link(@course)
    end
  end

  def edit
    @enrollment = Enrollment.find(params[:id])
    @subject_course = @enrollment.subject_course if @enrollment
    @exam_body = @subject_course.exam_body if @subject_course
    @exam_sittings = ExamSitting.where(subject_course_id: @subject_course.id).all_in_order
  end

  def update
    @enrollment = Enrollment.find(params[:id])

    if params[:custom_exam_date].present? && !params[:exam_date].present?
      date = params[:custom_exam_date]
    elsif !params[:custom_exam_date].present? && params[:exam_date].present?
      date = params[:exam_date]
    elsif params[:custom_exam_date].present? && params[:exam_date].present?
      date = params[:exam_date]
    end

    if @enrollment.update_attributes(exam_date: date, notifications: params[:enrollment][:notifications])
      redirect_to account_url(anchor: :enrollments)
    else
      redirect_to account_url(anchor: :enrollments)
    end

  end

  def send_welcome_email(user_id, course_name)
    MandrillWorker.perform_at(5.minute.from_now, user_id, 'send_enrollment_welcome_email', course_name, account_url)
  end

  protected

  #Only find and attach a SCUL if it's the first Enrollment
  def find_or_create_scul(course_id)
    #Users second+ Enrollment - so wants a new scul
    if current_user.enrolled_course_ids.include?(course_id)
      scul = SubjectCourseUserLog.create!(user_id: current_user.id, session_guid: current_session_guid, subject_course_id: course_id)
    else
      #Users first Enrollment for this course - so find or create new scul
      scul = current_user.subject_course_user_logs.where(subject_course_id: course_id).last
      if scul
        scul
      else
        scul = SubjectCourseUserLog.create!(user_id: current_user.id, session_guid: current_session_guid, subject_course_id: course_id)
      end
    end
    # Must return Id of a SCUL
    scul.id
  end

  def allowed_params
    params.require(:enrollment).permit(:subject_course_id, :exam_date, :subject_course_user_log_id)
  end

  def get_variables
    @user = current_user
  end

end
