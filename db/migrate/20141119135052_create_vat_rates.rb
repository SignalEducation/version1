class CreateVatRates < ActiveRecord::Migration[4.2]
  def change
    create_table :vat_rates do |t|
      t.integer :vat_code_id, index: true
      t.float :percentage_rate
      t.date :effective_from

      t.timestamps
    end
  end
end
