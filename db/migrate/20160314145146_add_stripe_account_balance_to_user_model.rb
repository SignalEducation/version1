class AddStripeAccountBalanceToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :stripe_account_balance, :integer, default: 0
  end
end
