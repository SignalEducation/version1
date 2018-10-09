class AddPaypalPlanIdToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :paypal_guid, :string
    add_column :subscription_plans, :description, :text
  end
end
