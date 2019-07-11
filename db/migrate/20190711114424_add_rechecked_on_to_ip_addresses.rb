class AddRecheckedOnToIpAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :ip_addresses, :rechecked_on, :datetime
  end
end
