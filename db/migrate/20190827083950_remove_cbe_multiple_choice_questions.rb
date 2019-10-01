class RemoveCbeMultipleChoiceQuestions < ActiveRecord::Migration[5.2]
  def change
    drop_table :cbe_multiple_choice_questions do |t|
      t.string :label
      t.boolean :is_correct_answer
      t.integer :order
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :question_1
      t.string :question_2
      t.string :question_3
      t.string :question_4
      t.integer :correct_answer
      t.string :name
      t.string :description
      t.bigint :cbe_section_id
      t.index ["cbe_section_id"], name: "index_cbe_multiple_choice_questions_on_cbe_section_id"
    end
  end
end


