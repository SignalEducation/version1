class RemoveSubjectCoursesUsersTable < ActiveRecord::Migration
  def change
    drop_table :subject_courses_users
    remove_column :users, :trial_ended_notification_sent_at, :datetime
    remove_column :users, :crush_offers_session_id, :string
    remove_column :users, :topic_interest, :string
    remove_column :users, :trial_limit_in_seconds, :integer
    remove_column :users, :trial_limit_in_days, :integer
    remove_column :users, :free_trial_ended_at, :datetime
    remove_column :users, :discourse_user, :boolean
  end
end
