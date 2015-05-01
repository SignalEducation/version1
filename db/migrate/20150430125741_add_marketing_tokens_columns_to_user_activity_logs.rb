class AddMarketingTokensColumnsToUserActivityLogs < ActiveRecord::Migration
  def change
    add_column :user_activity_logs, :marketing_token_id, :integer
    add_column :user_activity_logs, :marketing_token_cookie_issued_at, :datetime
  end
end
