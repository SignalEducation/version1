class ReorganiseInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :issued_at, :datetime, index: true
    remove_column :invoices, :unit_price_ex_vat, :decimal
    remove_column :invoices, :line_total_ex_vat, :decimal
    remove_column :invoices, :line_total_vat_amount, :decimal
    remove_column :invoices, :line_total_inc_vat, :decimal
    add_column :invoices, :stripe_guid, :string, index: true
    add_column :invoices, :sub_total, :decimal, default: 0
    add_column :invoices, :total, :decimal, default: 0
    add_column :invoices, :total_tax, :decimal, default: 0
    add_column :invoices, :stripe_customer_guid, :string, index: true
    add_column :invoices, :object_type, :string, default: 'invoice'
    add_column :invoices, :payment_attempted, :boolean, default: false
    add_column :invoices, :payment_closed, :boolean, default: false
    add_column :invoices, :forgiven, :boolean, default: false
    add_column :invoices, :paid, :boolean, default: false
    add_column :invoices, :livemode, :boolean, default: false
    add_column :invoices, :attempt_count, :integer, default: 0
    add_column :invoices, :amount_due, :decimal, default: 0
    add_column :invoices, :next_payment_attempt_at, :datetime
    add_column :invoices, :webhooks_delivered_at, :datetime
    add_column :invoices, :charge_guid, :string, index: true
    add_column :invoices, :subscription_guid, :string, index: true
    add_column :invoices, :tax_percent, :decimal
    add_column :invoices, :tax, :decimal
    add_column :invoices, :original_stripe_data, :text
  end
end
