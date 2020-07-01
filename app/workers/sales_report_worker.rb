# frozen_string_literal: true

class SalesReportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(period, date_interval, email)
    invoices = Invoice.where(created_at: date_interval, paid: true).subscriptions.order(:created_at)
    csv_data = invoices.to_csv

    send_to_email(csv_data, period, email)
  end

  private

  def send_to_email(csv_data, period, email)
    user = User.new(email: email, first_name: 'Sales', last_name: 'Report Bot')
    csv_encoded = Base64.encode64(csv_data)

    MandrillClient.new(user).send('send_report_email', csv_encoded, 'sales', period)
  end
end
