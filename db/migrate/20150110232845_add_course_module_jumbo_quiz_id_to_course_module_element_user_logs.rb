class AddCourseModuleJumboQuizIdToCourseModuleElementUserLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_user_logs, :course_module_jumbo_quiz_id, :integer, index: true
  end
end
