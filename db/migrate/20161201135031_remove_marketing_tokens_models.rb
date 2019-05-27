class RemoveMarketingTokensModels < ActiveRecord::Migration[4.2]
  def change
    drop_table :marketing_categories
    drop_table :marketing_tokens
  end
end
