# frozen_string_literal: true

json.call(@order, :id)
json.status        @order.state
json.client_secret @order.stripe_client_secret
json.url           order_complete_url(product_id: @order.product_id, order_id: @order.id)
