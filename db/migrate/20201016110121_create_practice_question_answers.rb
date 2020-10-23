class CreatePracticeQuestionAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :practice_question_answers do |t|
      t.json :content
      t.json :solution
      t.references :practice_question_question, foreign_key: true, index: { name: 'index_pq_answers_on_practice_question_question_id' }

      t.timestamps
    end
  end
end
