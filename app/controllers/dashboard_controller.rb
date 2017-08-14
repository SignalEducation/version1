class DashboardController < ApplicationController

  before_action :logged_in_required
  before_action only: [:admin] do
    ensure_user_is_of_type(%w(admin))
  end
  before_action only: [:export_users, :export_users_monthly, :export_courses] do
    ensure_user_is_of_type(%w(admin marketing_manager))
  end

  before_action :get_variables

  def admin
    @new_users = User.this_week.all_students
    @conversions = Subscription.this_week.all_active.all_of_status('active')
    free_trial_users = User.all_students.all_free_trial
    @free_trial_users = []
    free_trial_users.each do |user|
      @free_trial_users << user if user.valid_free_member?
    end
    @new_subscriptions = Subscription.this_week.all_active.all_of_status('active')
    @all_subscriptions = Subscription.all_active.all_of_status('active')
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

  def export_enrollments
    @enrollments = Enrollment.all_in_order.all_active

    respond_to do |format|
      format.html
      format.csv { send_data @enrollments.to_csv() }
      format.xls { send_data @enrollments.to_csv(col_sep: "\t", headers: true), filename: "enrolments-#{Date.today}.xls" }
    end
  end

  def export_users_with_enrollments
    @users = User.sort_by_recent_registration.all_students

    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv_with_enrollments() }
      format.xls { send_data @users.to_csv_with_enrollments(col_sep: "\t", headers: true), filename: "users-with-enrolments-#{Date.today}.xls" }
    end
  end

  def export_courses
    @courses = SubjectCourse.all_active.all_in_order

    respond_to do |format|
      format.html
      format.csv { send_data @courses.to_csv() }
      format.xls { send_data @courses.to_csv(col_sep: "\t", headers: true), filename: "courses-#{Date.today}.xls" }
    end
  end

  def export_visits
    @users = User.sort_by_recent_registration.all_students

    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv_with_visits() }
      format.xls { send_data @users.to_csv_with_visits(col_sep: "\t", headers: true), filename: "users-utm-data-#{Date.today}.xls" }
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

  def student
    @enrollments = Enrollment.includes(:subject_course_user_log).where(user_id: current_user.id).all_active.all_in_order
    enrollment_ids = @enrollments.map(&:subject_course_user_log_id)
    @logs = SubjectCourseUserLog.where(user_id: current_user.id).all_in_order
    log_ids = @logs.map(&:id)
    @non_enrollment_log_ids = log_ids - enrollment_ids
    @non_enrollment_logs = SubjectCourseUserLog.includes(subject_course: :group).where(id: @non_enrollment_log_ids)
    @acca_group = Group.all_active.all_in_order.first
    @cfa_group = Group.all_in_order.where(name_url: 'cfa-revision').first
    if @cfa_group
      @cfa_courses = @cfa_group.subject_courses.all_active
      cfa_course_ids = @cfa_courses.map(&:id)
      @cfa_logs = @logs.where(subject_course_id: cfa_course_ids)
    end
  end

  def tutor
    ensure_user_is_of_type(['tutor'])
  end

  def preview_csv_upload
    if params[:upload] && params[:upload].respond_to?(:read)
      @csv_data, @has_errors = User.parse_csv(params[:upload].read)
    else
      flash[:error] = t('controllers.dashboard.preview_csv.flash.error')
      redirect_to admin_dashboard_url
    end
  end

  def import_csv_upload
    if params[:csvdata]
      @users = User.bulk_create(params[:csvdata])
      @users.each do |user|
        if user.save
          if user.valid_free_member? && !user.stripe_customer_id
            MandrillWorker.perform_async(user.id, 'admin_invite', user_verification_url(email_verification_code: user.email_verification_code))
            stripe_customer = Stripe::Customer.create(email: user.email)
            user.update_attribute(:stripe_customer_id, stripe_customer.id)
          elsif !user.valid_free_member? && user.stripe_customer_id
            MandrillWorker.perform_async(user.id, 'send_free_trial_over_email', user_new_subscription_url(user.id))
          end
        end
      end
      flash[:success] = t('controllers.dashboard.import_csv.flash.success')
    else
      flash[:error] = t('controllers.dashboard.import_csv.flash.error')
      redirect_to admin_dashboard_url
    end
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
