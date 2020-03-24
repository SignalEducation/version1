class RemoveRecheckedOnFromIpAddresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :ip_addresses, :rechecked_on
  end
end
