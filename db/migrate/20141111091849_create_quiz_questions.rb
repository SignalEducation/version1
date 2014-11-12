class CreateQuizQuestions < ActiveRecord::Migration
  def change
    create_table :quiz_questions do |t|
      t.integer :course_module_element_quiz_id, index: true
      t.integer :course_module_element_id, index: true
      t.string :difficulty_level, index: true
      t.text :solution_to_the_question
      t.text :hints

      t.timestamps
    end
  end
end
