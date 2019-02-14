class RenameValidOnPaypalWebhooks < ActiveRecord::Migration[4.2]
  def change
    rename_column :paypal_webhooks, :valid, :verified
  end
end
