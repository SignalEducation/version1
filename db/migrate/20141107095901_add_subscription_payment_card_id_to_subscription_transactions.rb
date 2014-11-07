class AddSubscriptionPaymentCardIdToSubscriptionTransactions < ActiveRecord::Migration
  def change
    add_column :subscription_transactions, :subscription_payment_card_id, :integer, index: true
  end
end
