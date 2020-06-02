# frozen_string_literal: true

module Paypal
  class SubscriptionValidation
    include PayPal::SDK::REST

    STATUSES = {
      'Active' => 'active',
      'Suspended' => 'paused',
      'Cancelled' => 'cancelled'
    }.freeze

    class << self
      def run_paypal_sync
        Subscription.all_paypal.all_active.each do |sub|
          next unless sub.paypal_subscription_guid

          new(sub).sync_with_paypal
        end
      end
    end

    def initialize(subscription)
      @subscription = subscription
    end

    def sync_with_paypal
      agreement = Agreement.find(@subscription.paypal_subscription_guid)
      return if consistent_states(agreement.state)

      match_with_state(agreement)
    end

    private

    def consistent_states(state)
      return false unless STATUSES.key?(state)

      @subscription.send("#{STATUSES[state]}?") && @subscription.paypal_status == state
    end

    def update_paypal_status(status)
      return if @subscription.paypal_status == status

      @subscription.update(paypal_status: status)
    end

    def update_subscription_state(state)
      case state
      when 'Active'
        @subscription.restart!
      when 'Suspended'
        @subscription.pause!
      when 'Cancelled'
        @subscription.cancel!
      else
        Airbrake.notify("PAYPAL SYNC ERROR: Weird PayPal state for subscription #{@subscription.id}")
      end
    end

    def update_needed?(state)
      return true unless STATUSES.key?(state)

      STATUSES.key?(state) && !@subscription.send("#{STATUSES[state]}?")
    end

    def match_with_state(agreement)
      update_paypal_status(agreement.state)
      update_subscription_state(agreement.state) if update_needed?(agreement.state)
    rescue StateMachines::InvalidTransition => e
      log_to_airbrake(e.message)
    end

    def log_to_airbrake(message)
      Airbrake.notify("PAYPAL SYNC ERROR: Subscription #{@subscription.id}: #{message}")
    end
  end
end
