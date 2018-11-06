class CreateContentPageSections < ActiveRecord::Migration
  def change
    create_table :content_page_sections do |t|
      t.integer :content_page_id
      t.text :text_content
      t.string :panel_colour

      t.timestamps null: false
    end
  end
end
