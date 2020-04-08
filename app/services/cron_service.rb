# frozen_string_literal: true

class CronService
  TASK_LIST = %w[paypal_sync ping slack_exercises].freeze

  def initiate_task(task_name)
    raise(StandardError, "Cron Task #{task_name} is not defined") unless TASK_LIST.include?(task_name)

    send(task_name)
  end

  def ping
    Rails.logger.info 'CRON: I just got a PING'
  end

  def paypal_sync
    Rails.logger.info "CRON: Called the 'paypal_sync' task"
    Paypal::SubscriptionValidation.run_paypal_sync
  end

  def slack_exercises
    Rails.logger.info "CRON: Called the 'slack_exercises' task"
    Order.send_daily_orders_update
  end
end
