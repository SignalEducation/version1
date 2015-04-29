class CreateMarketingCategories < ActiveRecord::Migration
  def up
    create_table :marketing_categories do |t|
      t.string :name

      t.timestamps
    end

    MarketingCategory.create(name: "SEO and Direct")
  end

  def down
    drop_table :marketing_categories
  end
end
