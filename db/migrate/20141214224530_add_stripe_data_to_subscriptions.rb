class AddStripeDataToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :original_stripe_customer_data, :text
  end
end
