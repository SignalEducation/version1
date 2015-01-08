class CreateUserActivityLogs < ActiveRecord::Migration
  def change
    create_table :user_activity_logs do |t|
      t.integer :user_id, index: true
      t.string :session_guid, index: true
      t.boolean :signed_in, default: false, null: false
      t.string :original_uri, index: true
      t.string :controller_name, index: true
      t.string :action_name, index: true
      t.text :params
      t.integer :alert_level, index: true, default: 0

      t.timestamps
    end
  end
end
