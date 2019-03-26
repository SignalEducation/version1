class AddSectionUserLogIdToSetAndCmeul < ActiveRecord::Migration
  def change
    add_column :student_exam_tracks, :course_section_id, :integer
    add_column :student_exam_tracks, :course_section_user_log_id, :integer
    add_column :course_module_element_user_logs, :course_section_id, :integer
    add_column :course_module_element_user_logs, :course_section_user_log_id, :integer
    add_column :course_section_user_logs, :subject_course_id, :integer
  end
end
