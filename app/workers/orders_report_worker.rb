# frozen_string_literal: true

class OrdersReportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(period, date_interval, email)
    date     = format_date_period(date_interval)
    orders   = Order.where(created_at: date, state: 'completed')
    csv_data = orders.to_csv

    send_to_email(csv_data, period, email)
  end

  private

  def format_date_period(date_interval)
    return if date_interval.nil?

    date_array = date_interval.split('..')
    date_array.first.to_date..date_array.last.to_date.end_of_day
  end

  def send_to_email(csv_data, period, email)
    user = User.new(email: email, first_name: 'Products', last_name: 'Report Bot')
    csv_encoded = Base64.encode64(csv_data)

    MandrillClient.new(user).send('send_report_email', csv_encoded, 'products', period)
  end
end
