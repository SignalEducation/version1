# frozen_string_literal: true

class CronService
  TASK_LIST = %w[paypal_sync ping slack_exercises daily_sales_report monthly_sales_report
                 cumulative_monthly_sales_report monthly_refunds_report monthly_orders_report
                 daily_program_access_check].freeze

  def initiate_task(task_name)
    raise(StandardError, "Cron Task #{task_name} is not defined") unless TASK_LIST.include?(task_name)

    send(task_name)
  end

  def paypal_sync
    return if Rails.env.staging?

    Rails.logger.info "CRON: Called the 'paypal_sync' task"
    PaypalCronWorker.perform_async
  end

  def slack_exercises
    Rails.logger.info "CRON: Called the 'slack_exercises' task"
    Order.send_daily_orders_update
  end

  def daily_sales_report
    return if Rails.env.staging?

    Rails.logger.info "CRON: Called the 'daily_sales_report' task"
    SalesReportWorker.perform_async('daily', Time.zone.yesterday.all_day, MARKETING_EMAIL)
  end

  def cumulative_monthly_sales_report
    return if Rails.env.staging?

    Rails.logger.info "CRON: Called the 'cumulative_monthly_sales_report' task"
    SalesReportWorker.perform_async('cumulative', Time.zone.today.beginning_of_month..Time.zone.yesterday, MARKETING_EMAIL)
  end

  def monthly_sales_report
    return if Rails.env.staging?

    Rails.logger.info "CRON: Called the 'monthly_sales_report' task"
    SalesReportWorker.perform_async('monthly', Time.zone.yesterday.all_month, SALES_REPORT_EMAIL)
  end

  def monthly_refunds_report
    return if Rails.env.staging?

    Rails.logger.info "CRON: Called the 'monthly_refunds_report' task"
    RefundsReportWorker.perform_async('monthly', Time.zone.yesterday.all_month, SALES_REPORT_EMAIL)
  end

  def monthly_orders_report
    return if Rails.env.staging?

    Rails.logger.info "CRON: Called the 'monthly_orders_report' task"
    OrdersReportWorker.perform_async('monthly', Time.zone.yesterday.all_month, SALES_REPORT_EMAIL)
  end

  def daily_program_access_check
    Rails.logger.info "CRON: Called the 'daily_program_access_check' task"
    OrdersExpirationWorker.perform_async
  end
end
