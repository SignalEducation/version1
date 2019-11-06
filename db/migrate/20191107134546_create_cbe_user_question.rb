class CreateCbeUserQuestion < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_user_questions do |t|
      t.text :educator_comment
      t.float :score, default: 0
      t.boolean :correct, default: false

      t.timestamps
    end

    add_reference :cbe_user_questions, :cbe_user_log, index: true
    add_reference :cbe_user_questions, :cbe_question, index: true
  end
end
