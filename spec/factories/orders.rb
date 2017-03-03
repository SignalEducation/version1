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
#  current_status            :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#

FactoryGirl.define do
  factory :order do
    product_id 1
    subject_course_id 1
    user_id 1
    stripe_guid "MyString"
    stripe_customer_id "MyString"
    live_mode false
    current_status "MyString"
    coupon_code "MyString"
    terms_and_conditions true
    sequence(:reference_guid)      { |n| "Order_#{ApplicationController.generate_random_number(10)}#{n}" }
  end

end
