class DropStudentSubscriptionTransactionTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :subscription_transactions
  end
end
