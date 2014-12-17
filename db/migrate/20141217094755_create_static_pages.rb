class CreateStaticPages < ActiveRecord::Migration
  def change
    create_table :static_pages do |t|
      t.string :name
      t.datetime :publish_from
      t.datetime :publish_to
      t.boolean :allow_multiples, default: false, null: false
      t.string :public_url, index: true
      t.boolean :use_standard_page_template, default: false, null: false
      t.text :head_content
      t.text :body_content
      t.integer :created_by
      t.integer :updated_by
      t.boolean :add_to_navbar, default: false, null: false
      t.boolean :add_to_footer, default: false, null: false
      t.string :menu_label
      t.string :tooltip_text
      t.string :language
      t.boolean :mark_as_noindex, default: false, null: false
      t.boolean :mark_as_nofollow, default: false, null: false
      t.string :seo_title
      t.string :seo_description
      t.text :approved_country_ids
      t.boolean :default_page_for_this_url, default: false, null: false
      t.boolean :make_this_page_sticky, default: false, null: false

      t.timestamps
    end
  end
end
