# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default(FALSE)
#  active             :boolean          default(FALSE)
#  amount_off         :integer
#  duration           :string
#  duration_in_months :integer
#  max_redemptions    :integer
#  percent_off        :integer
#  redeem_by          :datetime
#  times_redeemed     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_coupon_data :text
#

FactoryBot.define do
  factory :coupon do
    sequence(:name)    { |n| "Coupon #{n}" }
    sequence(:code)    { |n| "code-#{n}" }
    currency
    livemode           { false }
    active             { true }
    amount_off         { nil }
    duration           { 'once' }
    duration_in_months { nil }
    max_redemptions    { 1 }
    percent_off        { 1 }
    redeem_by          { nil }
    times_redeemed     { 1 }
    stripe_coupon_data { 'Stripe Data' }

    trait :amount_kind do
      amount_off { rand(1..99) }
    end

    trait :percent_kind do
      percent_off { rand(1..99) }
    end

    trait :with_exam_body do
      exam_body
    end

    trait :list_subscriptions do
      after(:create) do |coupon|
        create_list(:subscription, 5, coupon: coupon)
      end
    end
  end
end
