class AddCouponIdToSubscriptionModel < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :coupon_id, :integer
    add_column :charges, :original_event_data, :text
  end
end
