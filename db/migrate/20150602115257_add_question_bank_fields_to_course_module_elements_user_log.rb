class AddQuestionBankFieldsToCourseModuleElementsUserLog < ActiveRecord::Migration
  def change
    add_column :course_module_element_user_logs, :is_question_bank, :boolean, default: true, null: false, index: true
    add_column :course_module_element_user_logs, :question_bank_id, :integer, index: true
  end
end
