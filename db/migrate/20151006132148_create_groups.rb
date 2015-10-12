class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, index: true
      t.string :name_url
      t.boolean :active, default: false, null: false
      t.integer :sorting_order
      t.text :description
      t.integer :subject_id, index: true

      t.timestamps null: false
    end
  end
end
