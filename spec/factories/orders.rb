# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  subject_course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default(FALSE)
#  stripe_status             :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#  paypal_guid               :string
#  paypal_status             :string
#  state                     :string
#

FactoryBot.define do
  factory :order do
    product
    subject_course
    user
    live_mode { false }
    terms_and_conditions { true }
    sequence(:reference_guid) { |n| "Order_#{ApplicationController.generate_random_number(10)}#{n}" }
  end

  trait :for_stripe do
    stripe_customer_id       'cus_test32423235243532'
    stripe_payment_method_id 'pm_32454254254353'
    stripe_payment_intent_id 'pi_542524553453254'
  end

  trait :for_paypal do
    use_paypal          true
    paypal_guid         'paypal_test_34252553'
    paypal_approval_url 'sandbox.paypal.com'
    paypal_status       'PENDING'
  end
end
