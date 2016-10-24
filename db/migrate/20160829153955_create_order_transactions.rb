class CreateOrderTransactions < ActiveRecord::Migration
  def change
    create_table :order_transactions do |t|
      t.integer :order_id, index: true
      t.integer :user_id, index: true
      t.integer :product_id, index: true
      t.string :stripe_order_id, index: true
      t.string :stripe_charge_id, index: true
      t.boolean :live_mode, default: false

      t.timestamps null: false
    end
  end
end
