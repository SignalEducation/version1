# == Schema Information
#
# Table name: subscriptions
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  subscription_plan_id     :integer
#  stripe_guid              :string(255)
#  next_renewal_date        :date
#  complimentary            :boolean          default("false"), not null
#  stripe_status            :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  stripe_customer_id       :string(255)
#  livemode                 :boolean          default("false")
#  active                   :boolean          default("false")
#  terms_and_conditions     :boolean          default("false")
#  coupon_id                :integer
#  paypal_subscription_guid :string
#  paypal_token             :string
#  paypal_status            :string
#  state                    :string
#  cancelled_at             :datetime
#  cancellation_reason      :string
#  cancellation_note        :text
#  changed_from_id          :bigint
#  completion_guid          :string
#  ahoy_visit_id            :uuid
#  cancelled_by_id          :bigint
#  kind                     :integer
#  paypal_retry_count       :integer          default("0")
#  total_revenue            :decimal(, )      default("0")
#

FactoryBot.define do
  factory :subscription do
    user
    subscription_plan
    next_renewal_date               { 6.days.from_now}
    complimentary                   { false }
    stripe_status                   { 'active' }
    livemode                        { false }
    terms_and_conditions            { true }
    sequence(:completion_guid)      { |n| "guid_#{n}" }
    kind                            { :new_subscription }

    factory :stripe_subscription do
      sequence(:stripe_guid) { |n| "sub_DUMMY-#{n}" }
      stripe_customer_id     { 'cus_1235455' }
    end

    factory :paypal_subscription do
      sequence(:paypal_subscription_guid) { |n| "sub_DUMMY-#{n}" }
      paypal_token                        { 'tok_1235455' }
      paypal_status                       { 'Active' }
    end

    factory :valid_subscription do
      stripe_status        { 'active' }
      active               { true }
    end

    factory :invalid_subscription do
      stripe_status        { 'canceled' }
      active               { true }
    end

    factory :active_subscription do
      stripe_status         { 'active' }
      active                { true }
    end

    factory :past_due_subscription do
      stripe_status        { 'past_due' }
      active               { true }
    end

    factory :canceled_pending_subscription do
      stripe_status        { 'canceled-pending' }
      state                { 'pending_cancellation' }
      active               { true }
    end

    factory :canceled_subscription do
      stripe_status        { 'canceled' }
      active               { true }
    end

    factory :unpaid_subscription do
      stripe_status        { 'unpaid' }
      active               { true }
    end
  end
end
