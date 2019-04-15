require 'paypal-sdk-rest'

class PaypalSubscriptionsService
  include Rails.application.routes.url_helpers
  include PayPal::SDK::REST

  def create_and_return_subscription(subscription)
    agreement = create_billing_agreement(subscription)
    subscription.assign_attributes(
      paypal_token: agreement.token,
      paypal_approval_url: agreement.links.find{|v| v.rel == "approval_url" }.href,
      paypal_status: agreement.state
    )
    subscription
  end

  def create_billing_agreement(subscription)
    agreement = Agreement.new(agreement_attributes(subscription))
    if agreement.create
      agreement
    else
      Rails.logger.error "DEBUG: Subscription#create Failure to create BillingAgreement - Error: #{agreement.inspect}"
      raise Learnsignal::SubscriptionError.new('Sorry Something went wrong with PayPal! Please contact us for assistance.')
    end
  rescue PayPal::SDK::Core::Exceptions::ServerError => e
    Rails.logger.error "DEBUG: Subscription#create Failure to create BillingAgreement - PayPal Error - Error: #{e.message}"
    raise Learnsignal::SubscriptionError.new('PayPal seems to be having issues right now. Please try again in a few minutes. If this problem continues, contact us for assistance.')
  end

  def execute_billing_agreement(subscription, token)
    agreement = Agreement.new()
    agreement.token = token
    if agreement.execute
      subscription.update!(
        paypal_status: agreement.state,
        complimentary: false,
        active: agreement.state != 'Cancelled',
        paypal_subscription_guid: agreement.id
      )
      agreement.state != 'Cancelled'
    else
      subscription.record_error!
      Rails.logger.error "DEBUG: Subscription#execute Failure to execute BillingAgreement for Subscription: ##{subscription.id} - Error: #{agreement.inspect}"
      raise Learnsignal::SubscriptionError.new('Sorry Something went wrong with PayPal! Please contact us for assistance.')
    end
  rescue PayPal::SDK::Core::Exceptions::ServerError
    Rails.logger.error "DEBUG: Subscription#execute Failure to execute BillingAgreement for Subscription: ##{subscription.id} - Paypal is 500-ing"
    raise Learnsignal::SubscriptionError.new('Paypal is currently not responding. Please try again.')
  end

  def suspend_billing_agreement(subscription)
    agreement = Agreement.find(subscription.paypal_subscription_guid)
    state_descriptor = AgreementStateDescriptor.new(note: 'Pausing the subscription')
    if agreement.suspend(state_descriptor)
      updated_agreement = Agreement.find(subscription.paypal_subscription_guid)
      subscription.update!(paypal_status: updated_agreement.state)
      subscription.pause
    else
      Rails.logger.error "DEBUG: Subscription#pause Failure to suspend BillingAgreement for Subscription: ##{subscription.id} - Error: #{agreement.inspect}"
      raise Learnsignal::SubscriptionError.new('Sorry! Something went wrong pausing your subscription with PayPal. Please contact us for assistance.')
    end
  end

  def reactivate_billing_agreement(subscription)
    agreement = Agreement.find(subscription.paypal_subscription_guid)
    state_descriptor = AgreementStateDescriptor.new(note: 'Re-activating the subscription')
    if agreement.re_activate(state_descriptor)
      subscription.update!(paypal_status: agreement.state)
      subscription.restart
    else
      Rails.logger.error "DEBUG: Subscription#re-activate Failure to re-activate BillingAgreement for Subscription: ##{subscription.id} - Error: #{agreement.inspect}"
      raise Learnsignal::SubscriptionError.new('Sorry! Something went wrong while re-activating your subscription with PayPal. Please contact us for assistance.')
    end
  end

  def cancel_billing_agreement(subscription)
    agreement = Agreement.find(subscription.paypal_subscription_guid)
    state_descriptor = AgreementStateDescriptor.new(note: "Cancelling the agreement")
    if agreement.cancel(state_descriptor)
      subscription.update!(paypal_status: agreement.state)
      subscription.cancel_pending
    else
      Rails.logger.error "DEBUG: Subscription#cancel Failure to cancel BillingAgreement for Subscription: ##{subscription.id} - Error: #{agreement.inspect}"
      raise Learnsignal::SubscriptionError.new('Sorry! Something went wrong cancelling your subscription with PayPal. Please contact us for assistance.')
    end
  end

  def update_next_billing_date(subscription)
    if subscription.paypal_subscription_guid
      agreement = Agreement.find(subscription.paypal_subscription_guid)
      subscription.update!(next_renewal_date: agreement.agreement_details.next_billing_date)
    end
  end

  def set_cancellation_date(subscription)
    agreement = Agreement.find(subscription.paypal_subscription_guid)
    subscription.update(paypal_status: agreement.state)
    if agreement.agreement_details.last_payment_date
      future = agreement.agreement_details.last_payment_date.to_time + 
        subscription.subscription_plan.payment_frequency_in_months.months
      SubscriptionCancellationWorker.perform_at(future, subscription.id)
    end
  end

  private

  def agreement_attributes(subscription)
    subscription_plan = subscription.subscription_plan
    {
      name: subscription_plan.name,
      description: subscription_plan.description.gsub("\n", ""),
      start_date: (Time.zone.now + subscription_plan.payment_frequency_in_months.months).iso8601,
      payer: {
        payment_method: "paypal",
        payer_info: {
          email: subscription.user.email,
          first_name: subscription.user.first_name,
          last_name: subscription.user.last_name
        }
      },
      override_merchant_preferences: {
        setup_fee: {
          value: subscription_plan.price.to_s,
          currency: subscription_plan.currency.iso_code
        },
        return_url: execute_subscription_url(id: subscription.id, host: learnsignal_host, payment_processor: 'paypal'),
        cancel_url: new_subscription_url(host: learnsignal_host, flash: 'It seems you cancelled your subscription on Paypal. Still want to upgrade?')
      },
      plan: {
        id: subscription_plan.paypal_guid
      }
    }
  end

  def learnsignal_host
    Rails.env.production? ? 'https://learnsignal.com' : 'https://staging.learnsignal.com'
  end
end
