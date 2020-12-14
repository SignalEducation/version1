class AddSolutionsModel < ActiveRecord::Migration[5.2]
  def change
    create_table :practice_question_solutions do |t|
      t.string :name
      t.integer :practice_question_id
      t.integer :sorting_order
      t.integer :kind
      t.json :content

      t.timestamps
    end
  end
end
