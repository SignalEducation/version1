class CreateContentPages < ActiveRecord::Migration[4.2]
  def change
    create_table :content_pages do |t|
      t.string :name, index: true
      t.string :public_url, index: true
      t.string :seo_title
      t.text :seo_description
      t.text :text_content
      t.string :h1_text
      t.string :h1_subtext
      t.string :nav_type
      t.boolean :footer_link, default: false, index: true

      t.timestamps null: false
    end
  end
end
