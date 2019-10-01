class CreateCbeUserAnswer < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_user_answers do |t|
      t.json :content

      t.timestamps
    end

    add_reference :cbe_user_answers, :cbe_user_log, index: true
    add_reference :cbe_user_answers, :cbe_question, index: true
    add_reference :cbe_user_answers, :cbe_answer, index: true
  end
end

