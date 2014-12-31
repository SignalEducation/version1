class RemoveTimeLimitSecondsFromCourseModuleElementQuizzes < ActiveRecord::Migration
  def up
    remove_column :course_module_element_quizzes, :time_limit_seconds
  end

  def down
    add_column :course_module_element_quizzes, :time_limit_seconds, :integer, default: 0
  end
end
