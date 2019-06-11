class AddPaypalPlanIdToSubscriptionPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :subscription_plans, :paypal_guid, :string
  end
end
