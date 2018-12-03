class AddPaypalStatusToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :paypal_status, :string
  end
end
