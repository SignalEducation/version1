class AddKindToInvoiceLineItem < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_line_items, :kind, :integer, default: 0
  end
end
