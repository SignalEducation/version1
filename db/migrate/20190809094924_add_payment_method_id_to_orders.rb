class AddPaymentMethodIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :stripe_payment_method_id, :string
    add_column :orders, :stripe_payment_intent_id, :string
  end
end
