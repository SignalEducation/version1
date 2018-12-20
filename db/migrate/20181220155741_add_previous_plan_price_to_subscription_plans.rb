class AddPreviousPlanPriceToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :previous_plan_price, :float, default: nil
  end
end
