class AddSecondsWatchedToCourseModuleElementUserLog < ActiveRecord::Migration
  def change
    add_column :course_module_element_user_logs, :seconds_watched, :integer, default: 0
  end
end
