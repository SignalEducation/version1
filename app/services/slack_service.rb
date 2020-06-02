# frozen_string_literal: true

class SlackService
  def notify_channel(channel, attachments, **options)
    message = {
      channel: "##{channel}",
      as_user: false,
      icon_emoji: options.fetch(:icon_emoji, ':female-student:'),
      username: options.fetch(:username, 'learnsignal bot'),
      attachments: attachments
    }
    send_notification(message)
  end

  def order_summary_attachment(orders)
    [{ fallback: 'Daily Orders Summary (Last 24hrs)',
       title: 'Daily Orders Summary (Last 24hrs)',
       color: '#7CD197',
       fields: [
         { title: 'Mock Exams', value: orders.product_type_count('mock_exam'), short: true },
         { title: 'General Corrections', value: orders.product_type_count('correction_pack'), short: true },
         { title: 'CBE', value: orders.product_type_count('cbe'), short: true }
       ] }]
  end

  private

  def order_attachment(orders)
    [{ fallback: 'Daily Orders Summary (Last 24hrs)',
       title: 'Daily Orders Summary (Last 24hrs)',
       color: '#7CD197',
       fields: [
         { title: 'Mock Exams', value: orders.product_type_count('mock_exam'),
           short: true },
         { title: 'General Corrections',
           value: orders.product_type_count('correction_pack'),
           short: true }
       ] }]
  end

  def slack_client
    @slack_client ||= Slack::Web::Client.new
  end

  def send_notification(message)
    slack_client.chat_postMessage(message)
  end
end
