class AddNotesCountInCourseLogsTables < ActiveRecord::Migration[5.2]
  def change
    add_column :course_logs, :count_of_notes_completed, :integer
    add_column :course_section_logs, :count_of_notes_taken, :integer
    add_column :course_lesson_logs, :count_of_notes_taken, :integer
  end
end
