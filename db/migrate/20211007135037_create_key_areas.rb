class CreateKeyAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :key_areas do |t|
      t.string "name"
      t.integer "sorting_order"
      t.boolean "active", default: false, null: false
      t.references :group, foreign_key: true, index: true
      t.timestamps
    end
  end
end
