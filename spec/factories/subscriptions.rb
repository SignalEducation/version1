# == Schema Information
#
# Table name: subscriptions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  subscription_plan_id :integer
#  stripe_guid          :string
#  next_renewal_date    :date
#  complimentary        :boolean          default(FALSE), not null
#  current_status       :string
#  created_at           :datetime
#  updated_at           :datetime
#  stripe_customer_id   :string
#  stripe_customer_data :text
#  livemode             :boolean          default(FALSE)
#  active               :boolean          default(FALSE)
#  terms_and_conditions :boolean          default(FALSE)
#  coupon_id            :integer
#

FactoryBot.define do
  factory :subscription do
    user_id               1
    subscription_plan_id  1
    sequence(:stripe_guid)      { |n| "sub_DUMMY-#{n}" }
    next_renewal_date     { 6.days.from_now}
    complimentary         false
    current_status        'active'
    livemode              false
    terms_and_conditions              true


    factory :valid_subscription do
      current_status        'active'
      active                true
    end

    factory :invalid_subscription do
      current_status        'canceled'
      active                true
    end

    factory :active_subscription do
      current_status        'active'
      active                true
    end

    factory :past_due_subscription do
      current_status        'past_due'
      active                true

    end

    factory :canceled_pending_subscription do
      current_status        'canceled-pending'
      active                true

    end

    factory :canceled_subscription do
      current_status        'canceled'
      active                true

    end

    factory :unpaid_subscription do
      current_status        'unpaid'
      active                true

    end


  end

end
