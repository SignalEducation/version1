class AddExhibitsModel < ActiveRecord::Migration[5.2]
  def change
    create_table :practice_question_exhibits do |t|
      t.string :name
      t.integer :practice_question_id
      t.integer :sorting_order
      t.integer :kind
      t.json :content
      t.attachment :document

      t.timestamps
    end
  end
end
