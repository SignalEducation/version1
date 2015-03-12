class CreateStripeDeveloperCalls < ActiveRecord::Migration
  def change
    create_table :stripe_developer_calls do |t|
      t.integer :user_id, index: true
      t.text :params_received
      t.boolean :prevent_delete, default: false, index: true

      t.timestamps
    end
  end
end
