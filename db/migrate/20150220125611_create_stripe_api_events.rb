class CreateStripeApiEvents < ActiveRecord::Migration
  def change
    create_table :stripe_api_events do |t|
      t.string :guid, index: true
      t.string :api_version, index: true
      t.text :payload
      t.boolean :processed, default: false, null: false, index: true
      t.datetime :processed_at, index: true
      t.boolean :error, default: false, null: false, index: true
      t.string :error_message

      t.timestamps
    end
  end
end
