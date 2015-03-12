class CreateInvoiceLineItems < ActiveRecord::Migration
  def change
    create_table :invoice_line_items do |t|
      t.integer :invoice_id, index: true
      t.decimal :amount
      t.integer :currency_id, index: true
      t.boolean :prorated
      t.datetime :period_start_at, index: true
      t.datetime :period_end_at, index: true
      t.integer :subscription_id, index: true
      t.integer :subscription_plan_id, index: true
      t.text :original_stripe_data

      t.timestamps
    end
  end
end
