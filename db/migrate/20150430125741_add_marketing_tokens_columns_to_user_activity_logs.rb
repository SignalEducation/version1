class AddMarketingTokensColumnsToUserActivityLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :user_activity_logs, :marketing_token_id, :integer, index: true
    add_column :user_activity_logs, :marketing_token_cookie_issued_at, :datetime
  end
end
