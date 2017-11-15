class DashboardController < ApplicationController

  before_action :logged_in_required
  before_action only: [:admin] do
    ensure_user_is_of_type(%w(admin))
  end

  before_action :get_variables

  def admin
    #@new_users = User.this_week.all_students
    #free_trial_users = User.all_students.all_free_trial
    #@free_trial_users = []
    #free_trial_users.each do |user|
    #  @free_trial_users << user if user.valid_free_member?
    #end
    #@new_subscriptions = Subscription.this_week.all_active.all_of_status('active')
    #@all_subscriptions = Subscription.all_active.all_valid
  end

  def content_manager
    ensure_user_is_of_type(['content_manager'])
  end

  def marketing_manager
    ensure_user_is_of_type(['marketing_manager'])
    @users = User.this_week.all_students
    @conversions = Subscription.this_week.all_active.all_of_status('active')
    @active_users = User.active_this_week.all_students
    @completed_cmes = CourseModuleElementUserLog.this_week.all_completed
  end

  def customer_support_manager
    ensure_user_is_of_type(['customer_support_manager'])
    @users = User.this_week.all_students
    @conversions = Subscription.this_week.all_active.all_of_status('active')
    @active_users = User.active_this_week.all_students
    @completed_cmes = CourseModuleElementUserLog.this_week.all_completed
  end

  def student
    @default_group = Group.all_active.all_in_order.first
    @enrollments = Enrollment.includes(:subject_course_user_log).where(user_id: current_user.id).all_valid.all_in_order

    @expired_enrollments = Enrollment.includes(:subject_course_user_log).where(user_id: current_user.id).all_active.all_expired.all_in_order
  end

  def tutor
    ensure_user_is_of_type(['tutor'])
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
