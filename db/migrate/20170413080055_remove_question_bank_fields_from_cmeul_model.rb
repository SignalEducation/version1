class RemoveQuestionBankFieldsFromCmeulModel < ActiveRecord::Migration[4.2]
  def change
    remove_column :course_module_element_user_logs, :question_bank_id, :integer
    remove_column :course_module_element_user_logs, :is_question_bank, :boolean
  end
end
