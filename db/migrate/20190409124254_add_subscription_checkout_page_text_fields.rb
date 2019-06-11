class AddSubscriptionCheckoutPageTextFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscription_plan_categories, :trial_period_in_days, :integer
    remove_column :subscription_plans, :trial_period_in_days, :integer
    remove_column :subscription_plans, :all_you_can_eat, :boolean, default: false, null: false
    remove_column :subscription_plans, :available_to_students, :boolean, default: false, null: false

    add_column :subscription_plan_categories, :sub_heading_text, :string
    add_column :subscription_plans, :bullet_points_list, :string
    add_column :subscription_plans, :sub_heading_text, :string
  end
end
