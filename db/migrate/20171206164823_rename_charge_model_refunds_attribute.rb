class RenameChargeModelRefundsAttribute < ActiveRecord::Migration
  def change
    rename_column :charges, :refunds, :stripe_refunds_data
  end
end
