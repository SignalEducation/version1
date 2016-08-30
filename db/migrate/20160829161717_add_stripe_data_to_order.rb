class AddStripeDataToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :stripe_order_payment_data, :text
  end
end
