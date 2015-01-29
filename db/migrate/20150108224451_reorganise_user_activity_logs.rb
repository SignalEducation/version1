class ReorganiseUserActivityLogs < ActiveRecord::Migration
  def change
    add_column :user_activity_logs, :browser, :string, index: true
    add_column :user_activity_logs, :operating_system, :string, index: true
    add_column :user_activity_logs, :phone, :boolean, default: false, null: false, index: true
    add_column :user_activity_logs, :tablet, :boolean, default: false, null: false, index: true
    add_column :user_activity_logs, :computer, :boolean, default: false, null: false, index: true
  end
end
