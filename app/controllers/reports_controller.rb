# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access user_management_access])
  end
  before_action :management_layout

  def index; end

  def sales; end

  def export_sales_report
    email         = sales_report_email(params[:period])
    date_interval = sales_report_date_interval(params[:period], params[:report][:start_date], params[:report][:final_date])

    SalesReportWorker.perform_async(params[:period], date_interval, email)

    flash[:success] = "Sales report it's been generating now, we'll send it to your email when it's done."

    redirect_to reports_path
  end

  def export_enrollments
    @exam_sitting = ExamSitting.find(params[:exam_sitting_id])
    @enrollments = @exam_sitting.enrollments.all_active.all_in_admin_order

    respond_to do |format|
      format.html
      format.csv { send_data @enrollments.to_csv }
      format.xls { send_data @enrollments.to_csv(col_sep: "\t", headers: true), filename: "#{@exam_sitting.name}-enrolments-#{Date.today}.xls" }
    end
  end

  def export_users_with_enrollments
    @users = User.sort_by_recent_registration.all_students

    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv_with_enrollments }
      format.xls { send_data @users.to_csv_with_enrollments(col_sep: "\t", headers: true), filename: "users-with-enrolments-#{Date.today}.xls" }
    end
  end

  def export_courses
    @courses = Course.all_active.all_in_order

    respond_to do |format|
      format.html
      format.csv { send_data @courses.to_csv }
      format.xls { send_data @courses.to_csv(col_sep: "\t", headers: true), filename: "courses-#{Date.today}.xls" }
    end
  end

  private

  def sales_report_email(period)
    case period
    when 'daily'
      MARKETING_EMAIL
    when 'monthly'
      SALES_REPORT_EMAIL
    else
      current_user.email
    end
  end

  def sales_report_date_interval(period, start_date, final_date)
    case period
    when 'daily'
      Time.zone.yesterday.all_day
    when 'monthly'
      Time.zone.yesterday.all_month
    else
      start_date..final_date
    end
  end
end
