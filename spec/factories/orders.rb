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
  end

end
