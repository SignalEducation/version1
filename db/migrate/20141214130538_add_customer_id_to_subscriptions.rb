class AddCustomerIdToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :stripe_customer_id, :string, index: true
  end
end
