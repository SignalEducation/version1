class DropStudentAccessTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :student_accesses
  end
end
