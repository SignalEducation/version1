class Mailers::OperationalMailers::SendUserNotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_notification_id)
    user_notification = UserNotification.find_by_id(user_notification_id)
    if user_notification
      OperationalMailer.send_user_notification(user_notification).deliver_now
    else
      Rails.logger.error "Mailers::OperationalMailers::SendUserNotificationWorker could not find notification ID #{user_notification_id}."
    end
  end
end
