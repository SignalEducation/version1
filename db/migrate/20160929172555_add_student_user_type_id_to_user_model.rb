class AddStudentUserTypeIdToUserModel < ActiveRecord::Migration
  def up
    add_column :users, :student_user_type_id, :integer, index: true
  end

  def down
    remove_column :users, :student_user_type_id, :integer, index: true
  end

end
