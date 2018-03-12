class AddComputerBasedBooleanToSubjectCourse < ActiveRecord::Migration
  def change
    add_column :subject_courses, :computer_based, :boolean, default: false, index: true
  end
end
