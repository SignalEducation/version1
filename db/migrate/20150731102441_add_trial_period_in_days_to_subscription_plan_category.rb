class AddTrialPeriodInDaysToSubscriptionPlanCategory < ActiveRecord::Migration
  def change
    add_column :subscription_plan_categories, :trial_period_in_days, :integer
  end
end
