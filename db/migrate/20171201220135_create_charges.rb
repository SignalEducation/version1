class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.integer :subscription_id, index: true
      t.integer :invoice_id, index: true
      t.integer :user_id, index: true
      t.integer :subscription_payment_card_id, index: true
      t.integer :currency_id, index: true
      t.integer :coupon_id, index: true
      t.integer :stripe_api_event_id, index: true
      t.string :stripe_guid
      t.integer :amount
      t.integer :amount_refunded
      t.string :failure_code
      t.text :failure_message
      t.string :stripe_customer_id
      t.string :stripe_invoice_id
      t.boolean :livemode, default: false
      t.string :stripe_order_id
      t.boolean :paid, index: true , default: false
      t.boolean :refunded, index: true , default: false
      t.text :refunds
      t.string :status, index: true

      t.timestamps null: false
    end
  end
end
