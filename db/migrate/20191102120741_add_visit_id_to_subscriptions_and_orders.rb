class AddVisitIdToSubscriptionsAndOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :ahoy_visit_id, :uuid
    add_column :orders, :ahoy_visit_id, :uuid
  end
end
