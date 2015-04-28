class CreateMarketingTokens < ActiveRecord::Migration
  def change
    create_table :marketing_tokens do |t|
      t.string :code
      t.integer :marketing_category_id
      t.boolean :is_hard, default: false, null: false
      t.boolean :is_direct, default: false, null: false
      t.boolean :is_seo, default: false, null: false

      t.timestamps
    end
  end
end
