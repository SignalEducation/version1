class AddQuizMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :quiz_answers, :quiz_question_id
    add_index :quiz_attempts, :course_module_element_user_log_id
    add_index :quiz_attempts, :quiz_answer_id
    add_index :quiz_attempts, :quiz_question_id
    add_index :quiz_attempts, :user_id
    add_index :quiz_contents, :quiz_answer_id
    add_index :quiz_contents, :quiz_question_id
    add_index :quiz_contents, :quiz_solution_id
    add_index :quiz_questions, :course_module_element_id
    add_index :quiz_questions, :course_module_element_quiz_id
    add_index :quiz_questions, :subject_course_id
  end
end
