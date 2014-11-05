class CreateQualifications < ActiveRecord::Migration
  def change
    create_table :qualifications do |t|
      t.integer :institution_id, index: true
      t.string :name
      t.string :name_url, index: true
      t.integer :sorting_order, index: true
      t.boolean :active, default: false, null: false
      t.integer :cpd_hours_required_per_year

      t.timestamps
    end
  end
end
