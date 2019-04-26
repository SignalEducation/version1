class AddGuidToUserActivityLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :user_activity_logs, :guid, :string, index: true
  end
end
