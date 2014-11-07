class CreateSubscriptionPaymentCards < ActiveRecord::Migration
  def change
    create_table :subscription_payment_cards do |t|
      t.integer :user_id, index: true
      t.string :stripe_card_guid, index: true
      t.string :status
      t.string :brand
      t.string :last_4
      t.integer :expiry_month
      t.integer :expiry_year
      t.string :billing_address
      t.string :billing_country
      t.integer :billing_country_id, index: true
      t.string :account_email

      t.timestamps
    end
  end
end
