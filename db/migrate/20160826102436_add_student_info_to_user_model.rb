class AddStudentInfoToUserModel < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :student_number, :string, index: true, default: nil
    add_column :users, :terms_and_conditions, :boolean, index: true, default: false
  end
end
