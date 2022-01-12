class CreateCategoriesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :name_url
      t.text :description
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
