class AddIsJumboQuizToCourseModuleElementUserLogs < ActiveRecord::Migration
  def change
    add_column :course_module_element_user_logs, :is_jumbo_quiz, :boolean, default: false, null: false, index: true
  end
end
