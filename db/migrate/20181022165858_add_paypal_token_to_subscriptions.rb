class AddPaypalTokenToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :paypal_token, :string
  end
end
