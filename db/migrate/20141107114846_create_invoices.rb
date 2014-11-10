class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :user_id, index: true
      t.integer :corporate_customer_id, index: true
      t.integer :subscription_transaction_id, index: true
      t.integer :subscription_id, index: true
      t.integer :number_of_users
      t.integer :currency_id, index: true
      t.decimal :unit_price_ex_vat
      t.decimal :line_total_ex_vat
      t.integer :vat_rate_id, index: true
      t.decimal :line_total_vat_amount
      t.decimal :line_total_inc_vat

      t.timestamps
    end
  end
end
