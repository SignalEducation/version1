# == Schema Information
#
# Table name: subscription_plan_categories
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  available_from :datetime
#  available_to   :datetime
#  guid           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :subscription_plan_category do
    sequence(:name)     { |n| "Subscription Plan Category #{n}" }
    available_from      { 1.week.ago }
    available_to        { 1.week.from_now }
  end

end
