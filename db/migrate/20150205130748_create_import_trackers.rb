class CreateImportTrackers < ActiveRecord::Migration
  def change
    create_table :import_trackers do |t|
      t.string :old_model_name, index: true
      t.integer :old_model_id, index: true
      t.string :new_model_name, index: true
      t.integer :new_model_id, index: true
      t.datetime :imported_at, index: true
      t.text :original_data

      t.timestamps
    end
  end
end
