class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :short_name
      t.string :name_url, index: true
      t.text :description
      t.string :feedback_url
      t.string :help_desk_url
      t.integer :subject_area_id
      t.integer :sorting_order, index: true
      t.boolean :active, default: false, null: false

      t.timestamps
    end
  end
end
