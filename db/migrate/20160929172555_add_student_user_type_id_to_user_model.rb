class AddStudentUserTypeIdToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :student_user_type_id, :integer, index: true
  end
end
