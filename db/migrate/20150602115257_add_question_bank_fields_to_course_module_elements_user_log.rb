class AddQuestionBankFieldsToCourseModuleElementsUserLog < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_user_logs, :is_question_bank, :boolean, default: false, null: false, index: true
    add_column :course_module_element_user_logs, :question_bank_id, :integer, index: true
  end
end
