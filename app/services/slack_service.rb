class SlackService

  def notify_channel(channel, attachments)
    message = {
      channel: "##{channel}",
      as_user: false,
      icon_emoji: ":female-student:",
      username: "learnsignal bot",
      attachments: attachments
    }
    send_notification(message)
  end

  private

  def slack_client
    @client ||= Slack::Web::Client.new
  end

  def send_notification(message)
    slack_client.chat_postMessage(message)
  end
end