require 'paypal-sdk-rest'

class PaypalSubscriptionsService
  include Rails.application.routes.url_helpers
  include PayPal::SDK::REST

  def initialize(subscription)
    @subscription = subscription
  end

  def create_and_return_subscription
    agreement = create_billing_agreement(subscription: @subscription)
    @subscription.assign_attributes(
      paypal_token: agreement.token,
      paypal_approval_url: agreement.links.find { |v| v.rel == 'approval_url' }.href,
      paypal_status: agreement.state
    )
    @subscription
  end

  def execute_billing_agreement(token)
    agreement = Agreement.new()
    agreement.token = token
    if agreement.execute
      @subscription.update!(
        paypal_status: agreement.state,
        complimentary: false,
        paypal_subscription_guid: agreement.id
      )
      agreement.state != 'Cancelled'
    else
      @subscription.record_error!
      raise_subscription_error(agreement, __method__.to_s, :paypal)
    end
  rescue PayPal::SDK::Core::Exceptions::ServerError
    raise_subscription_error(agreement, __method__.to_s, :paypal)
  end

  def cancel_billing_agreement(note: 'User cancelling the agreement')
    agreement = Agreement.find(@subscription.paypal_subscription_guid)
    if %w[Active Suspended].include?(agreement.state) && agreement.suspend(AgreementStateDescriptor.new(note: note))
      @subscription.update!(paypal_status: agreement.state)
      @subscription.cancel_pending
    else
      raise_subscription_error(agreement, __method__.to_s, :sub_cancellation)
    end
  end

  def un_cancel
    agreement = Agreement.find(@subscription.paypal_subscription_guid)
    note = AgreementStateDescriptor.new(note: 'Un-cancelling the subscription for the user')
    if agreement.state == 'Suspended' && agreement.re_activate(note)
      @subscription.update!(paypal_status: agreement.state)
      @subscription.restart
    else
      raise_subscription_error(agreement, __method__.to_s, :sub_cancellation)
    end
  end

  def cancel_billing_agreement_immediately
    agreement = Agreement.find(@subscription.paypal_subscription_guid)
    state_descriptor = AgreementStateDescriptor.new(note: 'Cancelling immediately')
    if agreement.state == 'Cancelled'
      @subscription.cancel
    elsif agreement.cancel(state_descriptor)
      @subscription.update!(paypal_status: agreement.state)
      @subscription.cancel unless @subscription.cancelled?
    else
      raise_subscription_error(agreement, __method__.to_s, :sub_cancellation)
    end
  end

  def update_next_billing_date
    return unless @subscription.paypal_subscription_guid

    agreement = Agreement.find(@subscription.paypal_subscription_guid)
    @subscription.update!(next_renewal_date: agreement.agreement_details.next_billing_date)
  end

  def set_cancellation_date
    agreement = Agreement.find(@subscription.paypal_subscription_guid)
    @subscription.update(paypal_status: agreement.state)
    return unless agreement.agreement_details.last_payment_date

    future = agreement.agreement_details.last_payment_date.to_time +
             @subscription.subscription_plan.payment_frequency_in_months.months
    PaypalSubscriptionCancellationWorker.perform_at(future, @subscription.id)
  end

  def change_plan(plan_id)
    agreement = Agreement.find(@subscription.paypal_subscription_guid)
    next_billing_date = next_billing_date(agreement.agreement_details.next_billing_date)
    if (new_subscription = create_new_subscription(plan_id, next_billing_date))
      cancel_billing_agreement(note: 'User changing plans') if %w[Active Suspended].include?(agreement.state)
      new_subscription
    else
      raise_subscription_error(agreement, __method__.to_s, :sub_change)
    end
  end

  def create_new_subscription(plan_id, start_date)
    new_subscription = @subscription.user.subscriptions.create(
      subscription_plan_id: plan_id,
      next_renewal_date: start_date,
      complimentary: false,
      changed_from: @subscription,
      kind: @subscription.kind
    )

    new_agreement = create_billing_agreement(
      subscription: new_subscription,
      start_date: start_date
    )
    new_subscription.update(
      paypal_token: new_agreement.token,
      paypal_approval_url: new_agreement.links.find { |v| v.rel == 'approval_url' }.href,
      paypal_status: new_agreement.state
    )
    new_subscription
  end

  private

  def create_billing_agreement(subscription:, start_date: nil)
    agreement = Agreement.new(agreement_attributes(subscription: subscription, start_date: start_date))
    if agreement.create
      agreement
    else
      raise_subscription_error(agreement, __method__.to_s, :paypal)
    end
  rescue PayPal::SDK::Core::Exceptions::ServerError
    raise_subscription_error(agreement, __method__.to_s, :paypal)
  end

  def subscription_start_date(plan)
    (Time.zone.now + plan.payment_frequency_in_months.months).iso8601
  end

  def next_billing_date(date)
    return if date.nil?

    Time.parse(date).iso8601
  end

  def agreement_attributes(subscription:, start_date: nil)
    subscription_plan = subscription.subscription_plan

    {
      name: subscription_plan.name,
      description: subscription_plan.description.delete("\n"),
      start_date: (start_date.nil? ? subscription_start_date(subscription_plan) : start_date),
      payer: {
        payment_method: 'paypal',
        payer_info: {
          email: subscription.user.email,
          first_name: subscription.user.first_name,
          last_name: subscription.user.last_name
        }
      },
      override_merchant_preferences: {
        setup_fee: subscription_setup_fee(start_date, subscription_plan),
        return_url: execute_subscription_url(id: subscription.id, host: LEARNSIGNAL_HOST, payment_processor: 'paypal'),
        cancel_url: cancel_url(subscription)
      },
      plan: {
        id: subscription_plan.paypal_guid
      }
    }
  end

  def subscription_setup_fee(start_date, subscription_plan)
    return {} if start_date

    {
      value: subscription_plan.price.to_s,
      currency: subscription_plan.currency.iso_code
    }
  end

  def cancel_url(subscription)
    if subscription.changed_from_id
      new_subscription_plan_changes_url(subscription_id: subscription.id, host: LEARNSIGNAL_HOST, payment_processor: 'paypal')
    else
      new_subscription_url(host: LEARNSIGNAL_HOST, flash: 'It seems you cancelled your subscription on Paypal. Still want to upgrade?')
    end
  end

  def raise_subscription_error(err, method, type, msg = '')
    error_msg = "PaypalSubscriptionService##{method} - #{err.inspect}"
    SegmentService.new.track_payment_failed_event(@subscription.user, @subscription, error_msg, 'error')
    Rails.logger.error error_msg
    raise Learnsignal::SubscriptionError, return_message(type, msg)
  end

  def return_message(type, msg = '')
    case type
    when :sub_cancellation
      'Sorry! Something went wrong cancelling the subscription with PayPal. Please try again.'
    when :sub_change
      'Sorry! Something went wrong changing your subscription with PayPal. Please contact us for assistance.'
    when :custom then msg
    when :paypal
      'Sorry Something went wrong with PayPal! Please contact us for assistance.'
    else
      'Sorry Something went wrong! Please contact us for assistance.'
    end
  end
end
