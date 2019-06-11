class CreateHomePages < ActiveRecord::Migration[4.2]
  def up
    create_table :home_pages do |t|
      t.string :seo_title
      t.string :seo_description
      t.integer :subscription_plan_category_id, index: true
      t.string :public_url, index: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :home_pages
  end
end
