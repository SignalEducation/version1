class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :iso_code, index: true
      t.string :name
      t.string :leading_symbol
      t.string :trailing_symbol
      t.boolean :active, index: true, default: false, null: false
      t.integer :sorting_order, index: true

      t.timestamps
    end
  end
end
