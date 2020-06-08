# frozen_string_literal: true

module Paypal
  class Subscription
    include PayPal::SDK::REST
    attr_reader :subscription, :agreement

    STATUSES = {
      'Active' => 'active',
      'Suspended' => 'paused',
      'Cancelled' => 'cancelled'
    }.freeze

    def initialize(subscription)
      @subscription = subscription
      @agreement = Agreement.find(@subscription.paypal_subscription_guid)
    end
  end
end
