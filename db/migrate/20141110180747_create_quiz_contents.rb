class CreateQuizContents < ActiveRecord::Migration
  def change
    create_table :quiz_contents do |t|
      t.integer :quiz_question_id, index: true
      t.integer :quiz_answer_id, index: true
      t.text :text_content
      t.boolean :contains_mathjax, default: false, null: false
      t.boolean :contains_image, default: false, null: false
      t.integer :sorting_order

      t.timestamps
    end
  end
end
