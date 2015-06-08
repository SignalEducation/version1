class CreateHomePages < ActiveRecord::Migration
  def change
    create_table :home_pages do |t|
      t.string :seo_title
      t.string :seo_description
      t.integer :subscription_plan_category_id, index: true
      t.string :public_url, index: true

      t.timestamps null: false
    end
  end
end
