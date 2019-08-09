class CreateCbeQuestionGroupings < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_question_groupings do |t|
      t.references :cbe, foreign_key: true
      t.references :cbe_section, foreign_key: true

      t.timestamps
    end
  end
end
