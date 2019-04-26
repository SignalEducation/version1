class AddSubscriptionPlanCategoryRefToUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :subscription_plan_category, index: true
  end
end
