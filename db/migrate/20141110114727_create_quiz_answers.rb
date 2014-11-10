class CreateQuizAnswers < ActiveRecord::Migration
  def change
    create_table :quiz_answers do |t|
      t.integer :quiz_question_id, index: true
      t.boolean :correct, default: false, null: false
      t.string :degree_of_wrongness, index: true
      t.text :wrong_answer_explanation_text
      t.integer :wrong_answer_video_id, index: true

      t.timestamps
    end
  end
end
