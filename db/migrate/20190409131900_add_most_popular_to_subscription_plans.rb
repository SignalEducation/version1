class AddMostPopularToSubscriptionPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :subscription_plans, :most_popular, :boolean, default: false, null: false
  end
end
