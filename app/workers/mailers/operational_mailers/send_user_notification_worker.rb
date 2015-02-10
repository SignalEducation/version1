class Mailers::OperationalMailers::SendUserNotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(user_notification_id)
    user_notification = UserNotification.find(user_notification_id)
    OperationalMailer.send_user_notification(user_notification).deliver
  end
end
