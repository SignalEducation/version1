require 'paypal-sdk-rest'

class PaypalPlansService
  include Rails.application.routes.url_helpers
  include PayPal::SDK::REST

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

  private

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
        max_fail_attempts: "4"
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
