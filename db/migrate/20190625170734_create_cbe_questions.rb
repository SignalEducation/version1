class CreateCbeQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_questions do |t|
      t.string :label
      t.text :description

      t.timestamps
    end
  end
end
