class CreateCbeQuestionTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_question_types do |t|
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
