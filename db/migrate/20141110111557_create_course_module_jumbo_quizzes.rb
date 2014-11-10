class CreateCourseModuleJumboQuizzes < ActiveRecord::Migration
  def change
    create_table :course_module_jumbo_quizzes do |t|
      t.integer :course_module_id, index: true
      t.string :name
      t.integer :minimum_question_count_per_quiz
      t.integer :maximum_question_count_per_quiz
      t.integer :total_number_of_questions

      t.timestamps
    end
  end
end
