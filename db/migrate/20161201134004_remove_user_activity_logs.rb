class RemoveUserActivityLogs < ActiveRecord::Migration[4.2]
  def change
    drop_table :user_activity_logs
  end
end
