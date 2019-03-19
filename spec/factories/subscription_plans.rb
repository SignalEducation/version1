# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  available_to_students         :boolean          default(FALSE), not null
#  all_you_can_eat               :boolean          default(TRUE), not null
#  payment_frequency_in_months   :integer          default(1)
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string
#  trial_period_in_days          :integer          default(0)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default(FALSE)
#  paypal_guid                   :string
#  paypal_state                  :string
#  monthly_percentage_off        :integer
#  previous_plan_price           :float
#  exam_body_id                  :bigint(8)
#

FactoryBot.define do
  factory :subscription_plan do
    organisation
    sequence(:name)                 { |n| "Test #{n}" }
    all_you_can_eat                 { true }
    payment_frequency_in_months     { 1 }
    association                     :currency
    price                           { 9.99 }
    available_from                  { 14.days.ago }
    available_to                    { 7.days.from_now }
    #stripe_guid                     'plan_ABC123123123'
    trial_period_in_days            7
    livemode                        false
    available_to_students           true


    factory :student_subscription_plan do
      available_to_students         { true }
      factory :student_subscription_plan_m do # monthly
        payment_frequency_in_months { 1 }
      end
      factory :student_subscription_plan_q do # quarterly
        payment_frequency_in_months { 3 }
      end
      factory :student_subscription_plan_y do # yearly
        payment_frequency_in_months { 12 }
      end
    end
  end
end
