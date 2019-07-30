class CreatePaymentIntents < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_intents do |t|
      t.string :intent_id
      t.string :client_secret
      t.string :currency
      t.string :next_action
      t.string :payment_method_options
      t.string :payment_method_types
      t.string :receipt_email
      t.string :status
      t.integer :amount
      t.string :charges
      t.jsonb :data

      t.timestamps
    end
  end
end
