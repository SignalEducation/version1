class AddStripeDataToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :stripe_order_payment_data, :text
  end
end
