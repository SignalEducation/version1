require 'paypal-sdk-rest'

class PaypalService
  include Rails.application.routes.url_helpers
  include PayPal::SDK::REST
  PayPal::SDK::REST.set_config(
    mode: "sandbox",
    client_id: "AajN5CdCcVFuea3nyJXXwZnAdkTxvgcd1IKeTcQVufHKl09WLTlmD5UKU7efXgC_VcZjUDTLveZ29FAt",
    client_secret: "EPF0A4akXxhuDx3BFKQGcEuYZw4_5sS13of5hX9MnjtvAVy1WmcPTj0cBk9lGxJ3TNqroDCTMC6PnaZc"
  )

  # PLANS ======================================================================

  def create_plan(subscription_plan)
    paypal_plan = Plan.new(plan_attributes(subscription_plan))
    paypal_plan.create
    update_subscription_plan(subscription_plan, paypal_plan)
    if paypal_plan.update(patch('replace', { state: 'ACTIVE' }))
      update_subscription_plan_state(subscription_plan, 'ACTIVE')
    end
  end

  def update_plan(subscription_plan)
    delete_plan(subscription_plan.paypal_guid)
    create_plan(subscription_plan)
  end

  def delete_plan(paypal_plan_id)
    plan = Plan.find(paypal_plan_id)
    plan.update(patch('replace', { state: 'DELETED' }))
  end

  # BILLING AGREEMENTS =========================================================

  def create_and_return_subscription(subscription)
    agreement = create_billing_agreement(subscription, subscription.user)
    subscription.assign_attributes(
      paypal_token: agreement.token,
      paypal_approval_url: agreement.links.find{|v| v.rel == "approval_url" }.href
    )
    subscription
  end

  def create_billing_agreement(subscription, user)
    agreement = Agreement.new(agreement_attributes(subscription, user))
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
      subscription.update(
        complimentary: false,
        active: true,
        current_status: agreement.state,
        paypal_subscription_guid: agreement.id,
        next_renewal_date: Time.parse(agreement.agreement_details.next_billing_date),
      )
    else
      Rails.logger.error "DEBUG: Subscription#create Failure to execute BillingAgreement for Subscription: ##{subscription.id} - Error: #{agreement.inspect}"
      raise Learnsignal::SubscriptionError.new('Sorry Something went wrong with PayPal! Please contact us for assistance.')
    end
  end

  def suspend_billing_agreement
    # 
  end

  def reactivate_billing_agreement
    # 
  end

  def cancel_billing_agreement
    # 
  end

  private

  def agreement_attributes(subscription, user)
    subscription_plan = subscription.subscription_plan
    {
      name: subscription_plan.name,
      description: subscription_plan.description.gsub("\n", ""),
      start_date: (Date.today + 1.month).iso8601,
      payer: {
        payment_method: "paypal",
        payer_info: {
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name
        }
      },
      override_merchant_preferences: {
        setup_fee: {
          value: subscription_plan.price.to_s,
          currency: subscription_plan.currency.iso_code
        },
        return_url: execute_subscription_url(id: subscription.id, host: 'https://staging.learnsignal.com', payment_processor: 'paypal'),
        cancel_url: unapproved_subscription_url(id: subscription.id, host: 'https://staging.learnsignal.com', payment_processor: 'paypal')
      },
      plan: {
        id: subscription_plan.paypal_guid
      }
    }
  end

  def patch(op, update_attributes)
    patch = Patch.new
    patch.op = op
    patch.path = "/"
    patch.value = update_attributes
    patch
  end

  def plan_attributes(subscription_plan)
    {
      name: "LearnSignal #{subscription_plan.name}",
      description: subscription_plan.description,
      type: "INFINITE",
      payment_definitions: [
        {
          name: "Regular payment definition",
          type: "REGULAR",
          frequency: "MONTH",
          frequency_interval: subscription_plan.payment_frequency_in_months.to_s,
          amount: {
            value: subscription_plan.price.to_s,
            currency: subscription_plan.currency.iso_code
          },
          cycles: "0",
        }
      ],
      merchant_preferences: {
        setup_fee: {
          value: "0",
          currency: subscription_plan.currency.iso_code
        },
        return_url: "https://example.com",
        cancel_url: "https://example.com/cancel",
        auto_bill_amount: "YES",
        initial_fail_amount_action: "CANCEL",
        max_fail_attempts: "0"
      }
    }
  end

  def update_subscription_plan(subscription_plan, paypal_plan)
    subscription_plan.update(
      paypal_guid: paypal_plan.id,
      paypal_state: paypal_plan.state
    )    
  end

  def update_subscription_plan_state(subscription_plan, state)
    subscription_plan.update(
      paypal_state: state
    ) 
  end
end
