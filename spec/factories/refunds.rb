# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  livemode           :boolean          default("true")
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryBot.define do
  factory :refund do
    sequence(:stripe_guid)                  { |n| "stripe-guid-#{n}" }
    sequence(:stripe_charge_guid)           { |n| "stripe-charge-guid-#{n}" }
    charge
    invoice
    subscription
    user
    association :manager, factory: :user
    amount { 1 }
    reason { 'requested_by_customer' }
    status { 'mystring' }
    stripe_refund_data { 'mystring' }
  end
end
