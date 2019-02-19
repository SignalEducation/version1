class AddComputerBasedBooleanToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :computer_based, :boolean, default: false, index: true
  end
end
