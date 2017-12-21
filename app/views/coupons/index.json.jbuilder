json.array!(@coupons) do |coupon|
  json.extract! coupon, :id, :stripe_id, :currency_id, :livemode, :active, :amount_off, :duration, :duration_in_months, :max_redemptions, :percent_off, :redeem_by, :times_redeemed, :valid
  json.url coupon_url(coupon, format: :json)
end
