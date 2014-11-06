class CreateSubscriptionTransactions < ActiveRecord::Migration
  def change
    create_table :subscription_transactions do |t|
      t.integer :user_id, index: true
      t.integer :subscription_id, index: true
      t.string :stripe_transaction_guid, index: true
      t.string :transaction_type, index: true
      t.decimal :amount
      t.integer :currency_id, index: true
      t.boolean :alarm, index: true, default: false, null: false
      t.boolean :live_mode, index: true, default: false, null: false
      t.text :original_data

      t.timestamps
    end
  end
end
