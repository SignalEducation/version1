# frozen_string_literal: true

class OrdersReportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform
    date_interval = Time.zone.yesterday.all_month
    orders = Order.where(created_at: date_interval)
    csv_data = orders.to_csv

    send_to_email(csv_data, 'monthly', SALES_REPORT_EMAIL)
  end

  private

  def send_to_email(csv_data, period, email)
    user = User.new(email: email, first_name: 'Products', last_name: 'Report Bot')
    csv_encoded = Base64.encode64(csv_data)

    MandrillClient.new(user).send('send_report_email', csv_encoded, 'products', period)
  end
end
