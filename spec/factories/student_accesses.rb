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

FactoryBot.define do
  factory :student_access do
    user
    trial_seconds_limit { ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i }
    trial_days_limit { ENV['FREE_TRIAL_DAYS'].to_i }
    content_seconds_consumed { 0 }
    account_type { 'Trial' }
    content_access { false }
    trial_started_date { (Time.now.to_datetime - 2.days) }
    trial_ending_at_date { (Time.now.to_datetime + 5) }


    factory :trial_student_access do
      trial_seconds_limit { 100 }
      trial_days_limit { 7 }
      content_seconds_consumed { 0 }
      account_type { 'Trial' }

      factory :valid_free_trial_student_access do
        content_access { true }
      end

      factory :invalid_free_trial_student_access do
        trial_ended_date { Time.now.to_datetime }
        content_access { false }
      end

      factory :unverified_trial_student_access do
        account_type { 'Trial' }
        content_access { false }
        trial_started_date { nil }
        trial_ending_at_date { nil }
      end

    end

    factory :subscription_student_access do
      account_type { 'Subscription' }
      content_access { true }

      factory :valid_subscription_student_access do
        content_access { true }
      end

      factory :invalid_subscription_student_access do
        content_access { false }
      end


    end

    factory :complimentary_student_access do
      account_type { 'Complimentary' }
      content_access { true }
    end

    factory :unverified_comp_student_access do
      account_type { 'Trial' }
      content_access { false }
      trial_started_date { nil }
      trial_ending_at_date { nil }
    end

  end

end
