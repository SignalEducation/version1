class CreateCbeQuestionStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_question_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
