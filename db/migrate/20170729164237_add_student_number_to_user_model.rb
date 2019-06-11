class AddStudentNumberToUserModel < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :student_number, :string, index: true
  end
end
