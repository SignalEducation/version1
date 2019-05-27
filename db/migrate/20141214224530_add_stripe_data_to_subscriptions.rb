class AddStripeDataToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :stripe_customer_data, :text
  end
end
