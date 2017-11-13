class AddParentIdsToCmeulAndSetModels < ActiveRecord::Migration
  def change
    add_column :course_module_element_user_logs, :student_exam_track_id, :integer, index: true
    add_column :course_module_element_user_logs, :subject_course_user_log_id, :integer, index: true
    add_column :student_exam_tracks, :subject_course_user_log_id, :integer, index: true
  end
end
