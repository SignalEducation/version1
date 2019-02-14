class CreateOrderItems < ActiveRecord::Migration[4.2]
  def change
    create_table :order_items do |t|
      t.integer :order_id
      t.integer :user_id
      t.integer :product_id
      t.string :stripe_customer_id
      t.decimal :price
      t.integer :currency_id
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
