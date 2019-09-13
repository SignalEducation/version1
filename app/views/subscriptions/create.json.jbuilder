# frozen_string_literal: true

json.subscription_id @subscription.id
json.status @subscription.stripe_status
json.completion_guid @subscription.completion_guid
json.client_secret @subscription.client_secret
