# frozen_string_literal: true

json.id plan.id
json.name                          plan.name
json.payment_frequency_in_months   plan.payment_frequency_in_months
json.price                         number_in_local_currency(plan.price, plan.currency)
json.guid                          plan.guid
json.stripe_guid                   plan.stripe_guid
json.paypal_guid                   plan.paypal_guid
json.paypal_state                  plan.paypal_state
json.available_from                plan.available_from
json.available_to                  plan.available_to
json.most_popular                  plan.most_popular
json.monthly_percentage_off        plan.monthly_percentage_off

json.currency do
  if plan.currency.present?
    json.id              plan.currency.id
    json.name            plan.currency.name
    json.iso_code        plan.currency.iso_code
    json.leading_symbol  plan.currency.leading_symbol
    json.trailing_symbol plan.currency.trailing_symbol
  else
    json.nil!
  end
end

json.subscription_plan_category_id do
  if plan.subscription_plan_category_id.present?
    json.id              plan.subscription_plan_category_id.id
    json.name            plan.subscription_plan_category_id.name
  else
    json.nil!
  end
end
