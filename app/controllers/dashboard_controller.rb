class DashboardController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables


  def show
    @default_group = Group.all_active.all_in_order.first
    @enrollments = Enrollment.includes(:subject_course_user_log).where(user_id: current_user.id).all_valid.all_in_recent_order

    @expired_enrollments = Enrollment.includes(:subject_course_user_log).where(user_id: current_user.id).all_active.all_expired.all_in_order
  end



  protected

  def get_variables
    @courses = SubjectCourse.all_active.all_in_order
    logs = SubjectCourseUserLog.where(user_id: current_user.id).all_in_order
    @all_active_logs = logs.where('percentage_complete < ?', 100)
    @first_active_log = @all_active_logs.first
    active_logs_ids = @all_active_logs.all.map(&:subject_course_id)
    @completed_logs = logs.where('percentage_complete > ?', 99)
    completed_logs_ids = @completed_logs.all.map(&:subject_course_id)
    @incomplete_courses = @courses.where(id: active_logs_ids)
    @completed_courses = @courses.where(id: completed_logs_ids)
    seo_title_maker('Dashboard', 'Progress through all your courses will be recorded here.', false)
  end

end
