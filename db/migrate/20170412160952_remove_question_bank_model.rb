class RemoveQuestionBankModel < ActiveRecord::Migration
  def change
    drop_table :question_banks
  end
end
