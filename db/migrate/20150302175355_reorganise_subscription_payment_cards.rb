class ReorganiseSubscriptionPaymentCards < ActiveRecord::Migration
  def change
    add_column :subscription_payment_cards, :address_line2, :string
    add_column :subscription_payment_cards, :address_city, :string
    add_column :subscription_payment_cards, :address_state, :string
    add_column :subscription_payment_cards, :address_zip, :string
    add_column :subscription_payment_cards, :address_country, :string
    rename_column :subscription_payment_cards, :billing_address, :address_line1
    rename_column :subscription_payment_cards, :billing_country, :account_country
    rename_column :subscription_payment_cards, :billing_country_id, :account_country_id
  end
end
