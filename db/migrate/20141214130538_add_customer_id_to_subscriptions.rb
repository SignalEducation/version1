class AddCustomerIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_customer_id, :string, index: true
  end
end
