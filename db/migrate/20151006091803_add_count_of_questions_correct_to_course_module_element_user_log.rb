class AddCountOfQuestionsCorrectToCourseModuleElementUserLog < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_user_logs, :count_of_questions_correct, :integer
  end
end
