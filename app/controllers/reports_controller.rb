class ReportsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables


  def index

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
    @enrollments = Enrollment.all_active.all_in_admin_order

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



  protected

  def get_variables
    seo_title_maker('System Reports', '', true)
  end

end