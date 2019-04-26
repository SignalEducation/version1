class AddIpAddressIdToUserActivityLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :user_activity_logs, :ip_address_id, :integer, index: true
  end
end
