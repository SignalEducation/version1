class RenameValidOnPaypalWebhooks < ActiveRecord::Migration
  def change
    rename_column :paypal_webhooks, :valid, :verified
  end
end
