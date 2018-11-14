class AddPaypalPaymentIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :paypal_payment_guid, :string
  end
end
