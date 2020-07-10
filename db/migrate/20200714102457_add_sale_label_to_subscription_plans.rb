class AddSaleLabelToSubscriptionPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :subscription_plans, :savings_label, :string
  end
end
