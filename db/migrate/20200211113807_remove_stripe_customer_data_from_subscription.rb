class RemoveStripeCustomerDataFromSubscription < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscriptions, :stripe_customer_data
  end
end
