class RemoveQuestionBankModel < ActiveRecord::Migration[4.2]
  def change
    drop_table :question_banks
  end
end
