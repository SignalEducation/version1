class AddOriginalStripeDataToCoupon < ActiveRecord::Migration[4.2]
  def change
    add_column :coupons, :stripe_coupon_data, :text
  end
end
