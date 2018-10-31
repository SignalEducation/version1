class AddPaypalSubscriptionIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :paypal_subscription_guid, :string
  end
end
