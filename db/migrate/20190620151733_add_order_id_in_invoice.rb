class AddOrderIdInInvoice < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :order, foreign_key: true
  end
end
