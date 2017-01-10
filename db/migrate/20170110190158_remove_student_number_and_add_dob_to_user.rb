class RemoveStudentNumberAndAddDobToUser < ActiveRecord::Migration
  def change
    remove_column :users, :student_number
    add_column :users, :date_of_birth, :date
  end
end
