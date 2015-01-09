class AddIpAddressToUserActivityLogs < ActiveRecord::Migration
  def change
    add_column :user_activity_logs, :ip_address, :string, index: true
  end
end
