class AddPaypalTokenToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :paypal_token, :string
  end
end
