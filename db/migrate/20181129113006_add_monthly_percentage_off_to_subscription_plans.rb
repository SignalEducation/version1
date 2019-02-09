class AddMonthlyPercentageOffToSubscriptionPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :subscription_plans, :monthly_percentage_off, :integer
  end
end
