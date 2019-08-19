class CreateCbeMultipleChoiceQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_multiple_choice_questions do |t|
      t.string :label
      t.boolean :is_correct_answer
      t.references :cbe_question_grouping, foreign_key: true
      t.integer :order

      t.timestamps
    end
  end
end
