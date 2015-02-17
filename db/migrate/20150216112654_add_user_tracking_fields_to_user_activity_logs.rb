class AddUserTrackingFieldsToUserActivityLogs < ActiveRecord::Migration
  def change
    add_column :user_activity_logs, :first_session_landing_page, :string, index: true
    add_column :user_activity_logs, :latest_session_landing_page, :string, index: true
    add_column :user_activity_logs, :post_sign_up_redirect_url, :string, index: true
  end
end
