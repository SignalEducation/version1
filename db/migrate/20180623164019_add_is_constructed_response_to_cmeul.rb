class AddIsConstructedResponseToCmeul < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_user_logs, :is_constructed_response, :boolean, default: false
  end
end
