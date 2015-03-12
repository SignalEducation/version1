class AddIpAddressIdToUserActivityLogs < ActiveRecord::Migration
  def change
    add_column :user_activity_logs, :ip_address_id, :integer, index: true
  end
end
