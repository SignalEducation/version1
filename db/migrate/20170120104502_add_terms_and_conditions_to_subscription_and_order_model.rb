class AddTermsAndConditionsToSubscriptionAndOrderModel < ActiveRecord::Migration
  def change
    add_column :subscriptions, :terms_and_conditions, :boolean, default: false, index: true
    add_column :orders, :terms_and_conditions, :boolean, default: false, index: true
  end
end
