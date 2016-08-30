class AddProductRequiredToSeeContentBooleanToUserGroups < ActiveRecord::Migration
  def change
    add_column :user_groups, :product_required_to_see_content, :boolean, default: false, index: true
    add_column :user_groups, :product_student, :boolean, default: false, index: true
  end
end
