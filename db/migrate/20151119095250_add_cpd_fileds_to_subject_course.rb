class AddCpdFiledsToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :is_cpd, :boolean, index: true, default: false
    add_column :subject_courses, :cpd_hours, :float
    add_column :subject_courses, :cpd_pass_rate, :integer
  end
end
