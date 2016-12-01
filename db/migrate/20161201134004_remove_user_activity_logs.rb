class RemoveUserActivityLogs < ActiveRecord::Migration
  def change
    drop_table :user_activity_logs
  end
end
