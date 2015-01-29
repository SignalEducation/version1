class LengthenOriginalUriInUserActivityLogs < ActiveRecord::Migration
  def up
    change_column :user_activity_logs, :original_uri, :text
  end

  def down
    change_column :user_activity_logs, :original_uri, :string
  end
end
