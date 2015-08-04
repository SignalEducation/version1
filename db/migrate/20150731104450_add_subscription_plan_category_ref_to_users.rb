class AddSubscriptionPlanCategoryRefToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :subscription_plan_category, index: true
  end
end
