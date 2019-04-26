class AddIpAddressToUserActivityLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :user_activity_logs, :ip_address, :string, index: true
  end
end
