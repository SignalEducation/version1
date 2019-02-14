class RenameChargeModelRefundsAttribute < ActiveRecord::Migration[4.2]
  def change
    rename_column :charges, :refunds, :stripe_refunds_data
  end
end
