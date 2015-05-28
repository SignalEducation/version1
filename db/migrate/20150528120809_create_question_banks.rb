class CreateQuestionBanks < ActiveRecord::Migration
  def change
    create_table :question_banks do |t|
      t.integer :user_id, index: true
      t.integer :exam_level_id, index: true
      t.integer :number_of_questions
      t.boolean :easy_questions, default: false, null: false
      t.boolean :medium_questions, default: false, null: false
      t.boolean :hard_questions, default: false, null: false

      t.timestamps null: false
    end
  end
end
