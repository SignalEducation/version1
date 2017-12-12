# == Schema Information
#
# Table name: charges
#
#  id                           :integer          not null, primary key
#  subscription_id              :integer
#  invoice_id                   :integer
#  user_id                      :integer
#  subscription_payment_card_id :integer
#  currency_id                  :integer
#  coupon_id                    :integer
#  stripe_api_event_id          :integer
#  stripe_guid                  :string
#  amount                       :integer
#  amount_refunded              :integer
#  failure_code                 :string
#  failure_message              :text
#  stripe_customer_id           :string
#  stripe_invoice_id            :string
#  livemode                     :boolean          default(FALSE)
#  stripe_order_id              :string
#  paid                         :boolean          default(FALSE)
#  refunded                     :boolean          default(FALSE)
#  stripe_refunds_data          :text
#  status                       :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  original_event_data          :text
#

FactoryGirl.define do
  factory :charge do
    subscription_id 1
    invoice_id 1
    user_id 1
    subscription_payment_card_id 1
    currency_id 1
    coupon_id 1
    stripe_api_event_id 1
    stripe_guid "MyString"
    amount 1
    amount_refunded 1
    failure_code "MyString"
    failure_message "MyText"
    stripe_customer_id "MyString"
    stripe_invoice_id "MyString"
    livemode false
    stripe_order_id "MyString"
    paid false
    refunded false
    refunds "MyText"
    status "MyString"
  end

end
