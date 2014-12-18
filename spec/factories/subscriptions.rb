# == Schema Information
#
# Table name: subscriptions
#
#  id                            :integer          not null, primary key
#  user_id                       :integer
#  corporate_customer_id         :integer
#  subscription_plan_id          :integer
#  stripe_guid                   :string(255)
#  next_renewal_date             :date
#  complementary                 :boolean          default(FALSE), not null
#  current_status                :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  stripe_customer_id            :string(255)
#  original_stripe_customer_data :text
#

FactoryGirl.define do
  factory :subscription do
    user_id               1
    corporate_customer_id 1
    subscription_plan_id  1
    stripe_guid           'sub_DUMMY-ABC123'
    next_renewal_date     { 6.days.from_now}
    complementary         false
    current_status        'active'
  end

end
