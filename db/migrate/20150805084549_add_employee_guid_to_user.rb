class AddEmployeeGuidToUser < ActiveRecord::Migration
  def change
    add_column :users, :employee_guid, :string
  end
end
