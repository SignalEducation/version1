class AddOriginalStripeDataToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :stripe_coupon_data, :text
  end
end
