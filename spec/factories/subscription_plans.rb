# == Schema Information
#
# Table name: subscription_plans
#
#  id                          :integer          not null, primary key
#  available_to_students       :boolean          default(FALSE), not null
#  available_to_corporates     :boolean          default(FALSE), not null
#  all_you_can_eat             :boolean          default(TRUE), not null
#  payment_frequency_in_months :integer          default(1)
#  currency_id                 :integer
#  price                       :decimal(, )
#  available_from              :date
#  available_to                :date
#  stripe_guid                 :string(255)
#  trial_period_in_days        :integer          default(0)
#  created_at                  :datetime
#  updated_at                  :datetime
#

FactoryGirl.define do
  factory :subscription_plan do
    all_you_can_eat             true
    payment_frequency_in_months 1
    currency_id                 1
    price                       9.99
    available_from              { 14.days.ago }
    available_to                { 7.days.from_now }
    stripe_guid                 'plan_ABC123123123'
    trial_period_in_days        7

    factory :student_subscription_plan do
      available_to_students     true
      available_to_corporates   false
    end

    factory :corporate_subscription_plan do
      available_to_students     false
      available_to_corporates   true
    end
  end

end
