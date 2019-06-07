class AddFormHeadingTextToSubscriptionPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :subscription_plans, :registration_form_heading, :string
    add_column :subscription_plans, :login_form_heading, :string
  end
end
