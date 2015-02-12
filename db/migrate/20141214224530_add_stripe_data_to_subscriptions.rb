class AddStripeDataToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_customer_data, :text
  end
end
