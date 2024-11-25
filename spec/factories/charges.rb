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
#  livemode                     :boolean          default("false")
#  stripe_order_id              :string
#  paid                         :boolean          default("false")
#  refunded                     :boolean          default("false")
#  stripe_refunds_data          :text
#  status                       :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  original_event_data          :text
#

FactoryBot.define do
  factory :charge do
    subscription
    invoice
    user
    subscription_payment_card
    currency
    coupon
    stripe_api_event
    stripe_guid { "MyString" }
    amount { 1 }
    amount_refunded { 1 }
    failure_code { "MyString" }
    failure_message { "MyText" }
    stripe_customer_id { "MyString" }
    stripe_invoice_id { "MyString" }
    livemode { false }
    stripe_order_id { "MyString" }
    paid { false }
    refunded { false }
    status { "MyString" }
  end
end
