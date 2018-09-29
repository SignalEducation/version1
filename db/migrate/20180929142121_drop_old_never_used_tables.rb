class DropOldNeverUsedTables < ActiveRecord::Migration
  def change
    drop_table :system_defaults
    drop_table :user_notifications
  end
end
