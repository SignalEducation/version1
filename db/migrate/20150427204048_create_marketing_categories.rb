class CreateMarketingCategories < ActiveRecord::Migration[4.2]
  def up
    create_table :marketing_categories do |t|
      t.string :name

      t.timestamps null: true
    end
  end

  def down
    drop_table :marketing_categories
  end
end
