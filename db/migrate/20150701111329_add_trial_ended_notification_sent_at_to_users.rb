class AddTrialEndedNotificationSentAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :trial_ended_notification_sent_at, :datetime
  end
end
