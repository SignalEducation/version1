class CreateVatCodes < ActiveRecord::Migration
  def change
    create_table :vat_codes do |t|
      t.integer :country_id, index: true
      t.string :name
      t.string :label
      t.string :wiki_url

      t.timestamps
    end
  end
end
