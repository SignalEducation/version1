class CreateMarketingTokens < ActiveRecord::Migration
  def up
    create_table :marketing_tokens do |t|
      t.string :code
      t.integer :marketing_category_id, index: true
      t.boolean :is_hard, default: false, null: false
      t.boolean :is_direct, default: false, null: false
      t.boolean :is_seo, default: false, null: false

      t.timestamps
    end

    unless Rails.env.test?
      MarketingToken.create(code: "seo", marketing_category_id: MarketingCategory.first.id, is_seo: true)
      MarketingToken.create(code: "direct", marketing_category_id: MarketingCategory.first.id, is_direct: true)
    end
  end

  def down
    drop_table :marketing_tokens
  end
end
