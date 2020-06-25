# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :logged_in_required
  before_action :management_layout
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access user_management_access])
  end
  before_action :management_layout
  before_action :report_params, only: %i[export_sales_report export_refunds_report export_orders_report]

  def index; end

  def sales; end

  def export_sales_report
    SalesReportWorker.perform_async(params[:period], @report_date_interval, @report_email)

    flash[:success] = "Sales report it's been generating now, we'll send it to your email when it's done."

    redirect_to reports_path
  end

  def export_refunds_report
    RefundsReportWorker.perform_async(params[:period], @report_date_interval, @report_email)

    flash[:success] = "Refunds report it's been generating now, we'll send it to your email when it's done."

    redirect_to reports_path
  end

  def export_orders_report
    OrdersReportWorker.perform_async(params[:period], @report_date_interval, @report_email)

    flash[:success] = "Orders report it's been generating now, we'll send it to your email when it's done."

    redirect_to reports_path
  end

  def export_sales_orders_report
    SalesOrdersReportWorker.perform_async(params[:period], @report_date_interval, @report_email)

    flash[:success] = "Sales/Orders report it's been generating now, we'll send it to your email when it's done."

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

  def export_messages
    @messages = Message.where(kind: 'onboarding', process_at: (Time.zone.now.beginning_of_month - 1.month)..(Time.zone.now))

    respond_to do |format|
      format.html
      format.csv { send_data @messages.to_csv() }
      format.xls { send_data @messages.to_csv(col_sep: "\t", headers: true), filename: "Onboarding-Messages-#{Date.today}.xls" }
    end
  end

  def export_onboarding
    @onboarding = OnboardingProcess.where(created_at: (Time.zone.now.beginning_of_month - 1.month)..(Time.zone.now.end_of_month - 1.month))

    respond_to do |format|
      format.html
      format.csv { send_data @onboarding.to_csv() }
      format.xls { send_data @onboarding.to_csv(col_sep: "\t", headers: true), filename: "Onboarding-Data-#{Date.today}.xls" }
    end
  end

  def export_onboarding_events
    onboarding = OnboardingProcess.where(created_at: (Time.zone.now.beginning_of_month - 1.month)..(Time.zone.now.end_of_month - 1.month))
    user_ids = onboarding.map(&:user_id)
    get_started_events = Ahoy::Event.all_get_started_events.where(user_id: user_ids, time: (Time.zone.now.beginning_of_month - 1.month)..(Time.zone.now.end_of_month - 1.month))
    visit_ids = get_started_events.map(&:visit_id)
    @visits = Ahoy::Visit.where(id: visit_ids)

    respond_to do |format|
      format.html
      format.csv { send_data @visits.events_to_csv() }
      format.xls { send_data @visits.events_to_csv(col_sep: "\t", headers: true), filename: "Onboarding-Data-#{Date.today}.xls" }
    end
  end

  def export_visits
    visit_ids = Ahoy::Event.all_registration_events.map(&:visit_id).uniq
    @visits = Ahoy::Visit.where(id: visit_ids, started_at: (Time.zone.now.beginning_of_month - 1.month)..(Time.zone.now.end_of_month - 1.month))

    respond_to do |format|
      format.html
      format.csv { send_data @visits.to_csv() }
      format.xls { send_data @visits.to_csv(col_sep: "\t", headers: true), filename: "Visit-Data-#{Date.today}.xls" }
    end
  end

  def export_new_subscriptions
    @subscriptions = Subscription.where(kind: :new_subscription, created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month).where.not(state: :pending)

    respond_to do |format|
      format.html
      format.csv { send_data @subscriptions.to_csv }
      format.xls { send_data @subscriptions.to_csv(col_sep: "\t", headers: true), filename: "new-subscriptions-#{Date.today}.xls" }
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

  def report_params
    @report_email         = report_email(params[:period])
    @report_date_interval = report_date_interval(params[:period],
                                                 params[:report][:start_date],
                                                 params[:report][:final_date])
  end

  def report_email(period)
    case period
    when 'daily'
      MARKETING_EMAIL
    when 'monthly'
      SALES_REPORT_EMAIL
    else
      current_user.email
    end
  end

  def report_date_interval(period, start_date, final_date)
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
