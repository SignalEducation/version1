class AddManagerIdToCorporateGroup < ActiveRecord::Migration
  def change
    add_column :corporate_groups, :corporate_manager_id, :integer, index: true
  end
end
