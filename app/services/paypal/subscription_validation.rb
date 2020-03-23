# frozen_string_literal: true

module Paypal
  class SubscriptionValidation
    include PayPal::SDK::REST

    class << self
      def run_paypal_sync
        Subscription.all_paypal.all_active.each do |sub|
          new(sub).sync_with_paypal
        end
      end
    end

    def initialize(subscription)
      @subscription = subscription
    end

    def sync_with_paypal
      agreement = Agreement.find(@subscription.paypal_subscription_guid)
      return if agreement.state == @subscription.paypal_status

      match_with_state(agreement)
    end

    private

    def match_with_state(agreement)
      case agreement.state
      when 'Active'
        log_to_airbrake unless @subscription.restart
      when 'Suspended'
        log_to_airbrake unless @subscription.pause
      when 'Cancelled'
        log_to_airbrake unless @subscription.cancel
      else
        Airbrake.notify("PAYPAL SYNC ERROR: Weird PayPal state for subscription #{@subscription.id}")
      end
    end

    def log_to_airbrake
      Airbrake.notify("PAYPAL SYNC ERROR: We ran into an error syncing subscription #{@subscription.id} with PayPal")
    end
  end
end
