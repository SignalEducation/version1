class AddPaypalStateToSubscriptionPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :subscription_plans, :paypal_state, :string
  end
end
