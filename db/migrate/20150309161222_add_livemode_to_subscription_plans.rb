class AddLivemodeToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :livemode, :boolean, default: false
  end
end
