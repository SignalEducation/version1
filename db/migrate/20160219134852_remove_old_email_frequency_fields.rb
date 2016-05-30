class RemoveOldEmailFrequencyFields < ActiveRecord::Migration
  def change
    remove_column :users, :operational_email_frequency, :string
    remove_column :users, :study_plan_notifications_email_frequency, :string
    remove_column :users, :falling_behind_email_alert_frequency, :string
    remove_column :users, :marketing_email_frequency, :string
    remove_column :users, :marketing_email_permission_given_at, :datetime
    remove_column :users, :blog_notification_email_frequency, :string
    remove_column :users, :forum_notification_email_frequency, :string
  end
end
