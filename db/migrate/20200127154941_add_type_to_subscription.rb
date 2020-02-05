class AddTypeToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :kind, :integer
  end
end
