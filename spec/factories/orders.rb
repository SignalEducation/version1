# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default("false")
#  stripe_status             :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default("false")
#  reference_guid            :string
#  paypal_guid               :string
#  paypal_status             :string
#  state                     :string
#  stripe_payment_method_id  :string
#  stripe_payment_intent_id  :string
#  ahoy_visit_id             :uuid
#

FactoryBot.define do
  factory :order do
    product
    course
    user
    live_mode { false }
    terms_and_conditions { true }
    sequence(:reference_guid) { |n| "Order_#{ApplicationController.generate_random_number(10)}#{n}" }
  end

  trait :for_stripe do
    stripe_customer_id       { 'cus_test32423235243532' }
    stripe_payment_method_id { 'pm_32454254254353' }
    stripe_payment_intent_id { 'pi_542524553453254' }
  end

  trait :for_paypal do
    use_paypal          { true }
    paypal_guid         { 'paypal_test_34252553' }
    paypal_approval_url { 'sandbox.paypal.com' }
    paypal_status       { 'PENDING' }
  end
end
