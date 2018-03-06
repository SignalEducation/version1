class AddExamSittingIdToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :exam_sitting_id, :integer, index: true
    add_column :enrollments, :computer_based_exam, :boolean, default: false, index: true
  end
end
