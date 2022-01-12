class AddGroupToCategoryAndSubCategory < ActiveRecord::Migration[5.2]
  def change
    add_reference :groups, :category, foreign_key: true
    add_reference :groups, :sub_category, foreign_key: true
  end
end
