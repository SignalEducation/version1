class AddComplimentaryBooleanToUserGroupAndRemoveOldProductFields < ActiveRecord::Migration[4.2]
  def change
    add_column :user_groups, :complimentary, :boolean, index: true, default: false
    remove_column :user_groups, :product_student, :boolean
    remove_column :user_groups, :product_required_to_see_content, :boolean
  end

end
