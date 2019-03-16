# == Schema Information
#
# Table name: subscriptions
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  subscription_plan_id     :integer
#  stripe_guid              :string
#  next_renewal_date        :date
#  complimentary            :boolean          default(FALSE), not null
#  stripe_status            :string
#  created_at               :datetime
#  updated_at               :datetime
#  stripe_customer_id       :string
#  stripe_customer_data     :text
#  livemode                 :boolean          default(FALSE)
#  active                   :boolean          default(FALSE)
#  terms_and_conditions     :boolean          default(FALSE)
#  coupon_id                :integer
#  paypal_subscription_guid :string
#  paypal_token             :string
#  paypal_status            :string
#  state                    :string
#  cancelled_at             :datetime
#  cancellation_reason      :string
#  cancellation_note        :text
#

FactoryBot.define do
  factory :subscription do
    user
    subscription_plan
    next_renewal_date     { 6.days.from_now}
    complimentary         { false }
    stripe_status         { 'active' }
    livemode              { false }
    terms_and_conditions  { true }
    active                { true }

    factory :stripe_subscription do
      sequence(:stripe_guid)      { |n| "sub_DUMMY-#{n}" }
    end

    factory :valid_subscription do
      stripe_status        { 'active' }
      active                { true }
    end

    factory :invalid_subscription do
      stripe_status        { 'canceled' }
      active                { true }
    end

    factory :active_subscription do
      stripe_status         { 'active' }
      active                { true }
    end

    factory :past_due_subscription do
      stripe_status        { 'past_due' }
      active                { true }
    end

    factory :canceled_pending_subscription do
      stripe_status        { 'canceled-pending' }
      active                { true }
    end

    factory :canceled_subscription do
      stripe_status        { 'canceled' }
      active                { true }
    end

    factory :unpaid_subscription do
      stripe_status        { 'unpaid' }
      active                { true }
    end
  end
end
