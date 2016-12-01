class RemoveMarketingTokensModels < ActiveRecord::Migration
  def change
    drop_table :marketing_categories
    drop_table :marketing_tokens
  end
end
