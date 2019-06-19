# frozen_string_literal: true

subscription_plan_stuff = {
  name: 'Personal',
  available_from: '2014-01-01',
  available_to: '2099-12-31'
}
# Euro
SubscriptionPlan.where(id: 1).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 1,
                                                 currency_id: 1,
                                                 exam_body_id: 1,
                                                 price: 9.99
                                               )); print '.'
SubscriptionPlan.where(id: 2).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 3,
                                                 currency_id: 1,
                                                 exam_body_id: 1,
                                                 price: 23.99
                                               )); print '.'
SubscriptionPlan.where(id: 3).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 12,
                                                 currency_id: 1,
                                                 exam_body_id: 1,
                                                 price: 99.99
                                               )); print '.'
SubscriptionPlan.where(id: 12).first_or_create!(subscription_plan_stuff.merge(
                                                  payment_frequency_in_months: 12,
                                                  currency_id: 1,
                                                  exam_body_id: 1,
                                                  price: 0.0
                                                )); print '.'
# Sterling
SubscriptionPlan.where(id: 4).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 1,
                                                 currency_id: 2,
                                                 exam_body_id: 1,
                                                 price: 7.99
                                               )); print '.'
SubscriptionPlan.where(id: 5).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 3,
                                                 currency_id: 2,
                                                 exam_body_id: 1,
                                                 price: 19.99
                                               )); print '.'
SubscriptionPlan.where(id: 6).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 12,
                                                 currency_id: 2,
                                                 exam_body_id: 1,
                                                 price: 79.99
                                               )); print '.'
SubscriptionPlan.where(id: 11).first_or_create!(subscription_plan_stuff.merge(
                                                  payment_frequency_in_months: 12,
                                                  currency_id: 2,
                                                  exam_body_id: 1,
                                                  price: 0.0
                                                )); print '.'

# US Dollar
SubscriptionPlan.where(id: 7).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 1,
                                                 currency_id: 3,
                                                 exam_body_id: 1,
                                                 price: 14.99
                                               )); print '.'
SubscriptionPlan.where(id: 8).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 3,
                                                 currency_id: 3,
                                                 exam_body_id: 1,
                                                 price: 29.99
                                               )); print '.'
SubscriptionPlan.where(id: 9).first_or_create!(subscription_plan_stuff.merge(
                                                 payment_frequency_in_months: 12,
                                                 currency_id: 3,
                                                 exam_body_id: 1,
                                                 price: 129.99
                                               )); print '.'
SubscriptionPlan.where(id: 10).first_or_create!(subscription_plan_stuff.merge(
                                                  payment_frequency_in_months: 12,
                                                  currency_id: 3,
                                                  exam_body_id: 1,
                                                  price: 0.0
                                                )); print '.'
