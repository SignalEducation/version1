class AddIsNoteInCourseStep < ActiveRecord::Migration[5.2]
  def change
    add_column :course_steps, :is_note, :boolean, default: false
    add_column :course_step_logs, :is_note, :boolean, default: false
  end
end
