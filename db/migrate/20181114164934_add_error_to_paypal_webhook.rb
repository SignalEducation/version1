class AddErrorToPaypalWebhook < ActiveRecord::Migration
  def change
    add_column :paypal_webhooks, :valid, :boolean, default: true
  end
end
