class AddExtraFieldsToUserActivityLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :user_activity_logs, :browser_version, :string, index: true
    add_column :user_activity_logs, :raw_user_agent, :string
  end
end
