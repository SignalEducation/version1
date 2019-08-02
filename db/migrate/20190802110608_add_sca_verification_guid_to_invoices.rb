class AddScaVerificationGuidToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :sca_verification_guid, :string, uniqueness: true
  end
end
