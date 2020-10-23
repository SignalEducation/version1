class AddPracticeQuestionsCountInCourseLogsTables < ActiveRecord::Migration[5.2]
  def change
    add_column :course_logs, :count_of_practice_questions_completed, :integer
    add_column :course_section_logs, :count_of_practice_questions_taken, :integer
    add_column :course_lesson_logs, :count_of_practice_questions_taken, :integer
  end
end
