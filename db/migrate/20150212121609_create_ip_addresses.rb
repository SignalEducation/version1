class CreateIpAddresses < ActiveRecord::Migration
  def change
    create_table :ip_addresses do |t|
      t.string :ip_address, index: true
      t.float :latitude, index: true
      t.float :longitude, index: true
      t.integer :country_id, index: true
      t.integer :alert_level

      t.timestamps
    end
  end
end
