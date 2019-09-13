class RemovePaymentIntentSecretFromInvoices < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :payment_intent_secret
  end
end
