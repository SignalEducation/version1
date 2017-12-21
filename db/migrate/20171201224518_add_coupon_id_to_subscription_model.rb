class AddCouponIdToSubscriptionModel < ActiveRecord::Migration
  def change
    add_column :subscriptions, :coupon_id, :integer
    add_column :charges, :original_event_data, :text
  end
end
