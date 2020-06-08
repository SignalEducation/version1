class AddPaypalRetryCountToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :paypal_retry_count, :integer, default: 0
  end
end
