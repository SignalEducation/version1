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
    trial_seconds_limit 1
    trial_days_limit 1
    content_seconds_consumed 1
    account_type 'Trial'
    content_access false



    factory :trial_student_access do
      trial_seconds_limit 100
      trial_days_limit 7
      content_seconds_consumed 0
      account_type 'Trial'

      factory :valid_trial_student_access do
        content_access true
      end

      factory :expired_trial_student_access do
        content_access false
      end

    end

    factory :subscription_student_access do
      account_type 'Subscription'
      content_access true
    end

  end

end
