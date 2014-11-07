class CreateCourseModuleElementQuizzes < ActiveRecord::Migration
  def change
    create_table :course_module_element_quizzes do |t|
      t.integer :course_module_element_id, index: true
      t.string :name
      t.text :preamble
      t.integer :expected_time_in_seconds
      t.integer :time_limit_seconds
      t.integer :number_of_questions
      t.string :question_selection_strategy
      t.integer :best_possible_score_first_attempt
      t.integer :best_possible_score_retry
      t.integer :course_module_jumbo_quiz_id, index: true

      t.timestamps
    end
  end
end
