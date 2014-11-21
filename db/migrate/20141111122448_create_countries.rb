class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name, index: true
      t.string :iso_code
      t.string :country_tld
      t.integer :sorting_order, index: true
      t.boolean :in_the_eu, index: true, default: false, null: false
      t.integer :currency_id, index: true

      t.timestamps
    end
  end
end
