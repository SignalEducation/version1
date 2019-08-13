# frozen_string_literal: true

subscription_plan_stuff = {
  name: 'Personal',
  available_from: '2014-01-01',
  available_to: '2029-01-31'
}
# Euro
SubscriptionPlan.first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 1,
                                                 currency_id: 1,
                                                 exam_body_id: 1,
                                                 price: 9.99
                                               )); print '.'