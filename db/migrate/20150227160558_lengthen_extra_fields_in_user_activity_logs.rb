class LengthenExtraFieldsInUserActivityLogs < ActiveRecord::Migration
  def up
    change_column :user_activity_logs, :first_session_landing_page, :text
    change_column :user_activity_logs, :latest_session_landing_page, :text
  end

  def down
    change_column :user_activity_logs, :first_session_landing_page, :string
    change_column :user_activity_logs, :latest_session_landing_page, :string
  end
end
