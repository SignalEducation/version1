class AddPreviewModeToCmeul < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_user_logs, :preview_mode, :boolean, default: false
  end
end
