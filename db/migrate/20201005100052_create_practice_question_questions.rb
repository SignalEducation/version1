class CreatePracticeQuestionQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :practice_question_questions do |t|
      t.integer :kind
      t.json :content
      t.json :solution
      t.integer :sorting_order
      t.references :course_practice_question, foreign_key: true, index: { name: 'index_pq_questions_on_course_practice_question_id' }

      t.timestamps
    end

  end
end
