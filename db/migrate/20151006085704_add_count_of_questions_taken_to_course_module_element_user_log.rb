class AddCountOfQuestionsTakenToCourseModuleElementUserLog < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_user_logs, :count_of_questions_taken, :integer
  end
end
