class CreateSubCategoriesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :sub_categories do |t|
      t.string :name
      t.string :name_url
      t.text :description
      t.boolean :active, default: false
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
