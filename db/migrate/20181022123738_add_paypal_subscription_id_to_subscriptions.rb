class AddPaypalSubscriptionIdToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :paypal_subscription_guid, :string
  end
end
