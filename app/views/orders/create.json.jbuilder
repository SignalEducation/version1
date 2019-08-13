# frozen_string_literal: true

json.call(@order, :id)
json.status        @order.state
json.client_secret @order.stripe_client_secret
