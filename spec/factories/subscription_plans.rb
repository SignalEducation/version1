# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  payment_frequency_in_months   :integer          default("1")
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string(255)
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default("false")
#  paypal_guid                   :string
#  paypal_state                  :string
#  monthly_percentage_off        :integer
#  previous_plan_price           :float
#  exam_body_id                  :bigint
#  guid                          :string
#  bullet_points_list            :string
#  sub_heading_text              :string
#  most_popular                  :boolean          default("false"), not null
#  registration_form_heading     :string
#  login_form_heading            :string
#  savings_label                 :string
#

FactoryBot.define do
  factory :subscription_plan do
    sequence(:name)                 { |n| "Test #{n}" }
    payment_frequency_in_months     { 1 }
    association                     :currency
    price                           { 9.99 }
    available_from                  { 14.days.ago }
    available_to                    { 7.days.from_now }
    #stripe_guid                     'plan_ABC123123123'
    livemode                        { false }
    exam_body


    factory :student_subscription_plan do
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
