class AddComplimentaryBooleanToUserGroupAndRemoveOldProductFields < ActiveRecord::Migration
  def up
    add_column :user_groups, :complimentary, :boolean, index: true, default: false
    remove_column :user_groups, :product_student, :boolean
    remove_column :user_groups, :product_required_to_see_content, :boolean

    unless Rails.env.test? || Rails.env.development?
      user_group = UserGroup.find 9
      user_group.update_attributes(complimentary: true, individual_student: false)
    end

  end

  def down
    remove_column :user_groups, :complimentary, :boolean, index: true, default: false
    add_column :user_groups, :product_student, :boolean
    add_column :user_groups, :product_required_to_see_content, :boolean
  end
end
