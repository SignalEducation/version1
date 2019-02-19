class AddSubscriptionPaymentCardIdToSubscriptionTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscription_transactions, :subscription_payment_card_id, :integer, index: true
  end
end
