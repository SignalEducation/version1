class AddExtraFieldsToSubscriptionPaymentCards < ActiveRecord::Migration
  def change
    add_column :subscription_payment_cards, :stripe_object_name, :string, index: true
    add_column :subscription_payment_cards, :funding, :string, index: true
    add_column :subscription_payment_cards, :cardholder_name, :string, index: true
    add_column :subscription_payment_cards, :fingerprint, :string, index: true
    add_column :subscription_payment_cards, :cvc_checked, :string, index: true
    add_column :subscription_payment_cards, :address_line1_check, :string, index: true
    add_column :subscription_payment_cards, :address_zip_check, :string, index: true
    add_column :subscription_payment_cards, :dynamic_last4, :string, index: true
    add_column :subscription_payment_cards, :customer_guid, :string, index: true
    add_column :subscription_payment_cards, :is_default_card, :boolean, default: false
    remove_column :subscription_payment_cards, :account_email, :string
  end
end
