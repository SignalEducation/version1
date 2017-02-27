class RemoveCorporateCustomerFields < ActiveRecord::Migration
  def change
    remove_column :subject_courses, :corporate_customer_id, :integer
    remove_column :subject_courses, :restricted, :boolean

    remove_column :groups, :corporate_customer_id, :integer

    remove_column :course_module_element_user_logs, :corporate_customer_id, :integer
    remove_column :invoices, :corporate_customer_id, :integer

    remove_column :subscriptions, :corporate_customer_id, :integer
    remove_column :subscription_plans, :available_to_corporates, :boolean

    remove_column :user_groups, :corporate_customer, :boolean
    remove_column :user_groups, :corporate_student, :boolean
    remove_column :user_groups, :subscription_required_at_sign_up, :boolean
    remove_column :user_groups, :subscription_required_to_see_content, :boolean

    remove_column :users, :employee_guid, :string
    remove_column :users, :corporate_customer_id, :integer

  end
end
