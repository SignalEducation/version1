# frozen_string_literal: true

json.array!(@orders) do |order|
  json.extract! order, :id, :product_id, :course_id, :user_id, :stripe_guid, :stripe_customer_id, :live_mode, :stripe_status, :coupon_code
  json.url order_url(order, format: :json)
end
