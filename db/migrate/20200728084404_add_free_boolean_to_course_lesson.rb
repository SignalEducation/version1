class AddFreeBooleanToCourseLesson < ActiveRecord::Migration[5.2]
  def change
    add_column :course_lessons, :free, :boolean, default: false, null: false, index: true
    add_column :onboarding_processes, :course_lesson_log_id, :integer, index: true
  end
end
