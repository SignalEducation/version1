class AddQuizAndVideoCompletationInCmeul < ActiveRecord::Migration[5.2]
  def change
    add_column :course_module_element_user_logs, :quiz_result, :integer
  end
end
