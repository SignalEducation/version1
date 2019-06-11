class AddLivemodeToSubscriptionPlans < ActiveRecord::Migration[4.2]
  def change
    add_column :subscription_plans, :livemode, :boolean, default: false
  end
end
