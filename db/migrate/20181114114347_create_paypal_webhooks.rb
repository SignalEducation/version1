class CreatePaypalWebhooks < ActiveRecord::Migration
  def change
    create_table :paypal_webhooks do |t|
      t.string :guid
      t.string :event_type
      t.text :payload
      t.datetime :processed_at

      t.timestamps null: false
    end
  end
end
