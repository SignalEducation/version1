class AddSubjectCourseIdToCmeuls < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_user_logs, :subject_course_id, :integer, index: true
  end
end
