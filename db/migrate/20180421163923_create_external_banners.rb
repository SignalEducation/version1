class CreateExternalBanners < ActiveRecord::Migration[4.2]
  def change
    create_table :external_banners do |t|
      t.string :name, index: true
      t.integer :sorting_order
      t.boolean :active, index: true, default: false
      t.string :background_colour
      t.text :text_content

      t.timestamps null: false
    end
  end
end
