class AddGuidToUserActivityLogs < ActiveRecord::Migration
  def change
    add_column :user_activity_logs, :guid, :string, index: true
  end
end
