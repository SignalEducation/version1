# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access user_management_access])
  end
  before_action :management_layout

  def index; end

  def export_sales_report
    @invoices = Invoice.where(created_at: Date.new(2020,05,01).to_time...Date.new(2020,06,01).to_time, paid: true).where.not(subscription_id: nil).order(:created_at)
    #@invoices = Invoice.from_yesterday.where(paid: true).where.not(subscription_id: nil).order(:created_at)

    respond_to do |format|
      format.html
      format.csv { send_data @invoices.to_csv() }
      format.xls { send_data @invoices.to_csv(col_sep: "\t", headers: true), filename: "May-Sales-Report.xls" }
    end
  end

  def export_enrollments
    @exam_sitting = ExamSitting.find(params[:exam_sitting_id])
    @enrollments = @exam_sitting.enrollments.all_active.all_in_admin_order

    respond_to do |format|
      format.html
      format.csv { send_data @enrollments.to_csv() }
      format.xls { send_data @enrollments.to_csv(col_sep: "\t", headers: true), filename: "#{@exam_sitting.name}-enrolments-#{Date.today}.xls" }
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
    @courses = Course.all_active.all_in_order

    respond_to do |format|
      format.html
      format.csv { send_data @courses.to_csv() }
      format.xls { send_data @courses.to_csv(col_sep: "\t", headers: true), filename: "courses-#{Date.today}.xls" }
    end
  end
end
