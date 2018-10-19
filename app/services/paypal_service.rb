require 'paypal-sdk-rest'

class PaypalService
  include PayPal::SDK::REST
  PayPal::SDK::REST.set_config(
    mode: "sandbox",
    client_id: "AajN5CdCcVFuea3nyJXXwZnAdkTxvgcd1IKeTcQVufHKl09WLTlmD5UKU7efXgC_VcZjUDTLveZ29FAt",
    client_secret: "EPF0A4akXxhuDx3BFKQGcEuYZw4_5sS13of5hX9MnjtvAVy1WmcPTj0cBk9lGxJ3TNqroDCTMC6PnaZc"
  )

  def create_plan(subscription_plan)
    paypal_plan = Plan.new(plan_attributes(subscription_plan))
    paypal_plan.create
    update_subscription_plan(subscription_plan, paypal_plan)
  end

  private

  def api_client
    @api ||= API.new
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
        initial_fail_amount_action: "CONTINUE",
        max_fail_attempts: "0"
      }
    }
  end

  def update_subscription_plan(subscription_plan, paypal_plan)
    subscription_plan.update(
      paypal_guid: paypal_plan.id
    )    
  end
end
