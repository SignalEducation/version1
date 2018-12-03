class AddPaypalStateToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :paypal_state, :string
  end
end
