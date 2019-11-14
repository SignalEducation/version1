class ChangeCbeUserAnswerReferences < ActiveRecord::Migration[5.2]
  def change
    remove_column :cbe_user_answers, :cbe_user_log_id, :integer
    remove_column :cbe_user_answers, :cbe_question_id, :integer
    remove_column :cbe_user_answers, :score, :float
    add_reference :cbe_user_answers, :cbe_user_question, index: true
  end
end
