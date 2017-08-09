class AddStudentNumberToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :student_number, :string, index: true
  end
end
