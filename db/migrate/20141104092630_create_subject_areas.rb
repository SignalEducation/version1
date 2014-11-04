class CreateSubjectAreas < ActiveRecord::Migration
  def up
    create_table :subject_areas do |t|
      t.string :name, index: true
      t.string :name_url, index: true
      t.integer :sorting_order, index: true
      t.boolean :active, default: false, null: false

      t.timestamps
    end
  end

  def down
    drop_table :subject_areas
  end
end
