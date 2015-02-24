class AddSubscriptionPlanCategoryStuff < ActiveRecord::Migration
  def change
    add_column :static_pages, :subscription_plan_category_id, :integer, index: true
    add_column :static_pages, :student_sign_up_h1, :string
    add_column :static_pages, :student_sign_up_sub_head, :string
    add_column :subscription_plans, :subscription_plan_category_id, :integer, index: true
  end
end
