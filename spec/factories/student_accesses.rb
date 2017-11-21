# == Schema Information
#
# Table name: student_accesses
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  trial_started_date       :datetime
#  trial_ending_at_date     :datetime
#  trial_ended_date         :datetime
#  trial_seconds_limit      :integer
#  trial_days_limit         :integer
#  content_seconds_consumed :integer          default(0)
#  subscription_id          :integer
#  account_type             :string
#  content_access           :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

FactoryGirl.define do
  factory :student_access do
    user_id 1
trial_start_date "2017-11-21 10:45:13"
trial_end_date "2017-11-21 10:45:13"
trial_seconds_limit 1
trial_days_limit 1
content_seconds_consumed 1
subscription_id 1
account_type "MyString"
content_access false
  end

end
