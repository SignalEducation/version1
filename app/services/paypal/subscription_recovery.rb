# frozen_string_literal: true

module Paypal
  class SubscriptionRecovery < Paypal::Subscription
    def initialize(subscription, agreement)
      @subscription = subscription
      @agreement = agreement
    end

    def outstanding_balance?
      outstanding_balance.positive?
    end

    def outstanding_balance
      @agreement.agreement_details.outstanding_balance&.value&.to_f
    end

    def bill_outstanding
      note = AgreementStateDescriptor.new(note: 'Billing the overdue balance')
      if @agreement.bill_balance(note: note,
                                 amount: {
                                   value: @agreement.agreement_details.outstanding_balance,
                                   currency: @subscription.currency.iso_code
                                 })
        process_recovery_success
      else
        process_recovery_failure
      end
    end

    private

    def process_recovery_failure
      @subscription.mark_past_due unless @subscription.past_due?
      @subscription.increment(:paypal_retry_count)
      return if @subscription.paypal_retry_count < 8

      PaypalSubscriptionsService.new(@subscription).cancel_billing_agreement_immediately
    end

    def process_recovery_success
      @subscription.restart unless @subscription.active?
      @subscription.update(paypal_retry_count: 0) if @subscription.paypal_retry_count.positive?
    end
  end
end
