class AddPaymentIntentSecretToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :requires_3d_secure, :boolean, default: false
    add_column :invoices, :payment_intent_secret, :string
  end
end
