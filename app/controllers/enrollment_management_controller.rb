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
#

class EnrollmentManagementController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(user_management_access))
  end
  before_action :get_variables

  def index
    @enrollments = Enrollment.all_in_recent_order

    if params[:search] && !params[:search].empty?
      @enrollments = Enrollment.search(params[:search]).all_in_recent_order
    elsif params[:exam_sitting] && params[:exam_sitting][:id]
      @enrollments = Enrollment.by_sitting(params[:exam_sitting][:id]).all_in_recent_order
    end

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
      redirect_to enrollment_management_url(@enrollment)
    else
      flash[:error] = t('controllers.enrollments.admin_update.flash.error')
      redirect_to enrollment_management_url(@enrollment)
    end

  end

  def show
    @enrollment = Enrollment.find(params[:id])
  end

  def create_new_scul
    @enrollment = Enrollment.find(params[:id])
    @course = @enrollment.subject_course

    if @enrollment
      scul = create_course_user_log(@course.id, @enrollment.user_id)

      if @enrollment.update_attribute(:subject_course_user_log_id, scul.id)
        flash[:success] = t('controllers.enrollments.admin_create_new_scul.flash.success')
      else
        flash[:error] = t('controllers.enrollments.admin_create_new_scul.flash.error')
      end
      redirect_to enrollment_management_url(@enrollment)
    end
  end

  protected

  def get_variables
    @layout = 'management'
  end

  def allowed_params
    params.require(:enrollment).permit(:exam_date, :subject_course_user_log_id, :exam_sitting_id, :notifications, :expired, :active)
  end

  def create_course_user_log(course_id, user_id)
    SubjectCourseUserLog.create!(user_id: user_id, subject_course_id: course_id)
  end

end
