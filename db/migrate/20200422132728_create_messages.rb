class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :user_id, index: true
      t.boolean :sent, default: false, null: false
      t.boolean :bounced, default: false, null: false
      t.boolean :rejected, default: false, null: false
      t.boolean :marked_as_spam, default: false, null: false
      t.integer :opened
      t.integer :clicked
      t.integer :kind, default: 0, null: false
      t.datetime :process_at, index: true
      t.string  :template
      t.string  :params
      t.string  :mandrill_id, index: true

      t.timestamps
    end
  end
end
