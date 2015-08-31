class RemoveUnusedAttributesFromCorporateCustomers < ActiveRecord::Migration
  def change
    remove_column :corporate_customers, :owner_id, :integer
    remove_column :corporate_customers, :can_restrict_content, :boolean
    remove_column :corporate_customers, :is_university, :boolean
  end
end
