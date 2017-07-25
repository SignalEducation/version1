class RemoveCourseModuleJumboQuizModel < ActiveRecord::Migration
  def change
    remove_column :course_module_element_quizzes, :is_final_quiz, :boolean
    remove_column :course_module_element_quizzes, :course_module_jumbo_quiz_id, :integer
    remove_column :course_module_element_user_logs, :course_module_jumbo_quiz_id, :integer
    remove_column :course_module_element_user_logs, :is_jumbo_quiz, :boolean
    remove_column :student_exam_tracks, :jumbo_quiz_taken, :boolean
  end
end
