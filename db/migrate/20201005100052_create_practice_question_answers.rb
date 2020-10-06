class CreatePracticeQuestionAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :practice_questions_answers do |t|
      t.integer :kind
      t.json :content
      t.json :solution
      t.integer :sorting_order
      t.references :course_practice_question, foreign_key: true, index: true

      t.timestamps
    end
  end
end
