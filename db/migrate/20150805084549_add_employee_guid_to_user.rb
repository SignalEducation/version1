class AddEmployeeGuidToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :employee_guid, :string
  end
end
