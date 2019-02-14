class AddPaypalStatusToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :paypal_status, :string
  end
end
