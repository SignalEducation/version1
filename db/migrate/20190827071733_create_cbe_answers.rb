class CreateCbeAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_answers do |t|
      t.integer :kind
      t.json :content

      t.timestamps
    end

    add_reference :cbe_answers, :cbe_question, index: true
  end
end
