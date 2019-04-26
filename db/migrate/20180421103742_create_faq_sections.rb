class CreateFaqSections < ActiveRecord::Migration[4.2]
  def change
    create_table :faq_sections do |t|
      t.string :name, index: true
      t.string :name_url, index: true
      t.text :description
      t.boolean :active, default: true, index: true
      t.integer :sorting_order, index: true

      t.timestamps null: false
    end
  end
end
