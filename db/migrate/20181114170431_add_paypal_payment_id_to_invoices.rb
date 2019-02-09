class AddPaypalPaymentIdToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :paypal_payment_guid, :string
  end
end
