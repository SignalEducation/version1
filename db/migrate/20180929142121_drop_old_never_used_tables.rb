class DropOldNeverUsedTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :system_defaults
    drop_table :user_notifications
  end
end
