class AddErrorToPaypalWebhook < ActiveRecord::Migration[4.2]
  def change
    add_column :paypal_webhooks, :valid, :boolean, default: true
  end
end
