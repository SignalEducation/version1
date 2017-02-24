class DashboardController < ApplicationController

  before_action :logged_in_required
  before_action only: [:admin] do
    ensure_user_is_of_type(['admin'])
  end
  before_action only: [:export_users, :export_users_monthly, :export_courses] do
    ensure_user_is_of_type(['admin', 'marketing_manager'])
  end

  before_action :get_variables

  def admin
    @users = User.this_week.all_students
    @conversions = Subscription.this_week.all_active.all_of_status('active')
    @active_users = User.active_this_week.all_students
    @completed_cmes = CourseModuleElementUserLog.this_week.all_completed
  end

  def export_users
    @users = User.sort_by_recent_registration.all_students

    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv() }
      format.xls { send_data @users.to_csv(col_sep: "\t", headers: true), filename: "total-users-#{Date.today}.xls" }
    end
  end

  def export_users_monthly
    @users = User.sort_by_recent_registration.this_month.all_students

    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv() }
      format.xls { send_data @users.to_csv(col_sep: "\t", headers: true), filename: "monthly-users-#{Date.today}.xls" }
    end
  end

  def export_courses
    @courses = SubjectCourse.all_active.all_live.all_in_order

    respond_to do |format|
      format.html
      format.csv { send_data @courses.to_csv() }
      format.xls { send_data @courses.to_csv(col_sep: "\t", headers: true), filename: "courses-#{Date.today}.xls" }
    end
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

  def corporate_student
    ensure_user_is_of_type(['corporate_student'])
    if current_user && current_user.corporate_student?
      if !current_user.restricted_subject_course_ids.empty?
        @permitted_courses = @courses.where('id not in (?)', current_user.restricted_subject_course_ids)
        @course_ids = @permitted_courses.map(&:id)
        @backup_courses =  @permitted_courses
      else
        @course_ids = @courses.map(&:id)
        @backup_courses =  @courses
      end
      @compulsory_courses = @courses.all_active.all_live.where(id: current_user.compulsory_subject_course_ids).all_in_order
      logs = SubjectCourseUserLog.where(user_id: current_user.id).all_in_order
      permitted_course_logs = logs.where(subject_course_id: @course_ids)
      @all_incomplete_logs = permitted_course_logs.where('percentage_complete < ?', 100)
      @all_completed_logs = permitted_course_logs.where('percentage_complete > ?', 99)
      @all_active_logs = @all_incomplete_logs + @all_completed_logs
      @other_active_logs = @all_active_logs[1..-1]
      @first_corp_log = permitted_course_logs.first

    end

  end

  def corporate_customer
    ensure_user_is_of_type(['corporate_customer'])
    if current_user && current_user.corporate_student?
      if !current_user.restricted_subject_course_ids.empty?
        @permitted_courses = @courses.where('id not in (?)', current_user.restricted_subject_course_ids)
        @course_ids = @permitted_courses.map(&:id)
        @backup_courses =  @permitted_courses
      else
        @course_ids = @courses.map(&:id)
        @backup_courses =  @courses
      end
      @compulsory_courses = @courses.all_active.all_live.where(id: current_user.compulsory_subject_course_ids).all_in_order
      logs = SubjectCourseUserLog.where(user_id: current_user.id).all_in_order
      permitted_course_logs = logs.where(subject_course_id: @course_ids)
      @all_incomplete_logs = permitted_course_logs.where('percentage_complete < ?', 100)
      @all_completed_logs = permitted_course_logs.where('percentage_complete > ?', 99)
      @all_active_logs = @all_incomplete_logs + @all_completed_logs
      @other_active_logs = @all_active_logs[1..-1]
      @first_corp_log = permitted_course_logs.first

    end

  end

  def student
    @enrollments = Enrollment.where(user_id: current_user.id, active: true).all_in_order
    enrollment_ids = @enrollments.map(&:subject_course_user_log_id)
    @logs = SubjectCourseUserLog.where(user_id: current_user.id).all_in_order
    log_ids = @logs.map(&:id)
    @non_enrollment_log_ids = log_ids - enrollment_ids
    @non_enrollment_logs = SubjectCourseUserLog.where(id: @non_enrollment_log_ids)
  end

  def tutor
    ensure_user_is_of_type(['tutor'])
  end

  protected

  def get_variables
    @courses = SubjectCourse.all_active.all_live.all_in_order
    logs = SubjectCourseUserLog.where(user_id: current_user.id).all_in_order
    @all_active_logs = logs.where('percentage_complete < ?', 100)
    @first_active_log = @all_active_logs.first
    active_logs_ids = @all_active_logs.all.map(&:subject_course_id)
    @completed_logs = logs.where('percentage_complete > ?', 99)
    completed_logs_ids = @completed_logs.all.map(&:subject_course_id)
    @compulsory_logs = SubjectCourseUserLog.where(user_id: current_user.id)
    @incomplete_courses = @courses.where(id: active_logs_ids)
    @completed_courses = @courses.where(id: completed_logs_ids)
    seo_title_maker('Dashboard', 'Progress through all your courses will be recorded here.', false)
  end

end
