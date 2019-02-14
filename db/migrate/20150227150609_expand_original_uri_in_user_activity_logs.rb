class ExpandOriginalUriInUserActivityLogs < ActiveRecord::Migration[4.2]
  def up
    change_column :user_activity_logs, :original_uri, :text
  end

  def down
    change_column :user_activity_logs, :original_uri, :string
  end
end
