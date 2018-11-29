class AddMonthlyPercentageOffToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :monthly_percentage_off, :integer
  end
end
