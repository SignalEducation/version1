class CreateQuestionBanks < ActiveRecord::Migration
  def change
    create_table :question_banks do |t|
      t.integer :user_id, index: true
      t.integer :exam_level_id, index: true
      t.integer :easy_questions, index: true
      t.integer :medium_questions, index: true
      t.integer :hard_questions, index: true
      t.string :question_selection_strategy

      t.timestamps null: false
    end
  end
end
