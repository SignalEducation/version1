class AddIsConstructedResponseToCmeul < ActiveRecord::Migration
  def change
    add_column :course_module_element_user_logs, :is_constructed_response, :boolean, default: false
  end
end
